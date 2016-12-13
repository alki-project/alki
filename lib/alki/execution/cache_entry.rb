module Alki
  module Execution
    class CacheEntry
      attr_accessor :type,:value,:status
      def initialize
        @status = :building
      end

      def finish(type,value)
        @status = :done
        @type = type
        @value = value
      end
    end
  end
end
