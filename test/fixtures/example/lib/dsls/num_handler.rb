Alki do
  dsl_method :num_handler do |name, num|
    ctx[:module].service name do
      require 'example/num_handler'
      Example::NumHandler.new(num,settings.send(name),output)
    end
  end
end
