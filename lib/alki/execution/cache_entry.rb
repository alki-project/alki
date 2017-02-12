require 'concurrent/immutable_struct'

module Alki
  module Execution
    class CacheEntry < Concurrent::ImmutableStruct.new(:type,:value,:status)
      def self.building
        new nil, nil, :building
      end

      def self.finished(type,value)
        new type, value, :done
      end
    end
  end
end
