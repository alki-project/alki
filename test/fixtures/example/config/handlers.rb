Alki do
  use 'example/dsls/num_handler'

  factory :num_handler do
    require 'example/num_handler'
    -> (num,str) {
      Example::NumHandler.new(num, str, output)
    }
  end

  num_handler :fizz, 3

  group :handlers do
    num_handler :buzz, 5
  end

  service :buzz do
    handlers.buzz
  end

  service :fizzbuzz do
    num_handler 15, settings.fizzbuzz
  end

  tag :io
  service :echo do
    require 'example/echo_handler'
    Example::EchoHandler.new output
  end
end
