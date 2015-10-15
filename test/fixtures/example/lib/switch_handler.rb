class SwitchHandler
  def initialize(handlers)
    @handlers = handlers
  end

  def handle(val)
    @handlers.find {|h| h.handle val }
  end
end