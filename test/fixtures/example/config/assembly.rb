Alki do
  mount :alki

  load :settings
  load :handlers

  factory :log_overlay do
    require 'example/log_overlay'
    -> (obj) {
      # Don't overlay services in subgroups (names with multiple periods)
      if meta[:building] =~ /\..*\./
        obj
      else
        alki.delegate_overlay(
          obj,
          Example::LogOverlay.new(log),
          name: meta[:building]
        )
      end
    }
  end

  overlay :handlers, :log_overlay

  service :handler do
    require 'example/switch_handler'
    Example::SwitchHandler.new [
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
    require 'example/range_handler'
    Example::RangeHandler.new lazy('handler')
  end

  service :output do
    require 'example/array_output'
    Example::ArrayOutput.new
  end

  service :log_io do
    require 'stringio'
    StringIO.new
  end

  mount :tlogger do
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
