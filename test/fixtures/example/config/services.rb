Alki do
  service :fizz do
    require 'num_handler'
    NumHandler.new 3, settings.fizz, output
  end
  service :buzz do
    require 'num_handler'
    NumHandler.new 5, settings.buzz, output
  end
  service :fizzbuzz do
    require 'num_handler'
    NumHandler.new 15, settings.fizzbuzz, output
  end
  service :echo do
    require 'echo_handler'
    EchoHandler.new output
  end
  service :handler do
    require 'switch_handler'
    SwitchHandler.new [fizzbuzz, fizz, buzz, echo]
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