class RangeHandler
  def initialize(subhandler)
    @subhandler = subhandler
  end

  def handle(range)
    range.each do |i|
      @subhandler.handle i
    end
  end
end