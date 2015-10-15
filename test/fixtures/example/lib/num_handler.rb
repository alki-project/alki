class NumHandler
  def initialize(num,message,output)
    @num = num
    @msg = message
    @output = output
  end

  def handle(val)
    @output << @msg if val % @num == 0
  end
end