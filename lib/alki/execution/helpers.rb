require 'alki/service_delegator'

module Alki
  module Execution
    module Helpers
      def lookup(*path)
        path.flatten.inject(self) do |from_group,elem|
          unless elem.is_a?(String) or elem.is_a?(Symbol)
            raise ArgumentError.new("lookup can only take Strings or Symbols")
          end
          elem.to_s.split('.').inject(from_group) do |group,name|
            raise "Invalid lookup elem" unless group.is_a? Helpers
            if name =~ /^\d/
              group[name.to_i]
            else
              group.send name.to_sym
            end
          end
        end
      end

      def lazy(*path)
        path = path.flatten.inject('') do |new_path,elem|
          unless elem.is_a?(String) or elem.is_a?(Symbol)
            raise ArgumentError.new("lookup can only take Strings or Symbols")
          end
          new_path << elem.to_s
        end
        Alki::ServiceDelegator.new self, path
      end

      def reference(path,*args,&blk)
        __reference__ path, args, blk
      end
    end
  end
end
