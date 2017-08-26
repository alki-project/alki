module Alki
  class CircularReferenceError < RuntimeError
    attr_reader :chain

    def initialize
      @chain = []
      super
    end

    def to_s
      "Circular Alki element reference:\n#{formatted_chain}"
    end

    def formatted_chain
      chain.reverse.map do |path|
        p = path.join('.')
        if path == chain[0]
          "> #{p}"
        else
          "  #{p}"
        end
      end.join("\n")
    end
  end
end
