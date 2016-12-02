Alki do
  load :settings
  load :handlers

  service :handler do
    require 'switch_handler'
    SwitchHandler.new [
                        handlers.fizzbuzz,
                        handlers.fizz,
                        handlers.buzz,
                        handlers.echo
                      ]
  end

  func :run do |range|
    range_handler.handle range
  end

  service :range_handler do
    require 'range_handler'
    RangeHandler.new lazy('handler')
  end

  service :output do
    require 'array_output'
    ArrayOutput.new
  end

  service :log_io do
    require 'stringio'
    StringIO.new
  end

  assembly :tlogger do
    set :io do
      log_io
    end
  end

  service :log do
    tlogger.log
  end

  service :message_proc do
    -> (msg) {
      msg[0].upcase+msg[1..-1].downcase+"!"
    }
  end
end