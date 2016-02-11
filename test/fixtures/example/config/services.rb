Alki do
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
  service :range_handler do
    require 'range_handler'
    RangeHandler.new handler
  end
  service :output do
    require 'array_output'
    ArrayOutput.new
  end
  service :message_proc do
    -> (msg) {
      msg[0].upcase+msg[1..-1].downcase+"!"
    }
  end
end