module Example
  class SwitchHandler
    def initialize(handlers)
      @types = handlers
    end

    def handle(val)
      @types.find {|h| h.handle val }
    end
  end
end
