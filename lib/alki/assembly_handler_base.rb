module Alki
  class AssemblyHandlerBase
    def initialize(elem,data,key=nil)
      @elem = elem
      @data = data
      @key = key
    end

    attr_reader :elem, :data, :key

    def index
      raise NotImplementedError.new("Can't index into this element")
    end

    def output
      raise NotImplementedError.new("Can't output this element")
    end
  end
end