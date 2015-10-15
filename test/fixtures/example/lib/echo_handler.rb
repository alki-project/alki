class EchoHandler
  def initialize(output)
    @output = output
  end

  def handle(val)
    @output << val.to_s
  end
end