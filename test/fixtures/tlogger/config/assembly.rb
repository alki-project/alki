Alki do
  set :io do
    raise "Most override io service"
  end

  service :log do
    require 'logger'
    Logger.new io
  end
end