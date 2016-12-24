require 'alki/service_delegator'

module Alki
  module Execution
    module Helpers
      def lookup(*path)
        path.flatten.inject(self) do |group,elem|
          unless elem.is_a?(String) or elem.is_a?(Symbol)
            raise ArgumentError.new("lookup can only take Strings or Symbols")
          end
          elem.to_s.split('.').inject(group) do |group,name|
            raise "Invalid lookup elem" unless group.is_a? Helpers
            group.send name.to_sym
          end
        end
      end

      def lazy(*path)
        path = path.flatten.inject('') do |path,elem|
          unless elem.is_a?(String) or elem.is_a?(Symbol)
            raise ArgumentError.new("lookup can only take Strings or Symbols")
          end
          path << elem.to_s
        end
        Alki::ServiceDelegator.new self, path
      end
    end
  end
end
