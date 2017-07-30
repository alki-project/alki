module Example
  class ArrayOutput
    def initialize
      @output = []
    end
    def <<(val)
      @output << val
    end
    def to_a
      @output.dup
    end
  end
end
