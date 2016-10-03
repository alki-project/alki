Alki do
  factory :num_handler do
    require 'num_handler'
    -> (num,str) {
      NumHandler.new num, str, output
    }
  end
  service :fizz do
    num_handler 3, settings.fizz
  end
  service :buzz do
    num_handler 5, settings.buzz
  end
  service :fizzbuzz do
    num_handler 15, settings.fizzbuzz
  end
  service :echo do
    require 'echo_handler'
    EchoHandler.new output
  end

  overlay do
    log_obj = log
    -> (name,obj,method,*args,&blk) {
      log_obj << "Calling #{name}##{method} #{args.join(", ")}\n"
      obj.public_send method, *args, &blk
    }
  end
end