Alki do
  dsl_method :num_handler do |name, num|
    ctx[:module].service name do
      require 'num_handler'
      NumHandler.new(num,settings.send(name),output)
    end
  end
end
