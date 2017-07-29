Alki do
  use 'example/dsls/num_handler'

  factory :num_handler do
    require 'num_handler'
    -> (num,str) {
      NumHandler.new(num, str, output)
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

  service :echo do
    require 'echo_handler'
    EchoHandler.new output
  end
end
