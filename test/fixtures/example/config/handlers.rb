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
end