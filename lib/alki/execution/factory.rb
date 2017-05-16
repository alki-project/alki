require 'forwardable'

module Alki
  module Execution
    class Factory
      extend Forwardable

      def initialize(method)
        @method = method
      end

      def_delegators :@method, :call, :to_proc, :to_s, :[]
      def_delegator :@method, :call, :new
    end
  end
end
