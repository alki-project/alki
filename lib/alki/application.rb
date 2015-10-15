module Alki
  class Application
    attr_reader :settings

    def configure(&blk)
      self.instance_exec(&blk)
    end

    def initialize(settings={},root_group = Group.new)
      unless root_group.is_a? Group
        raise ArgumentError.new("Argument must be a group object")
      end
      @group = root_group
      @settings = settings
    end

    def root_group
      @group
    end

    def respond_to_missing?(name,include_private = true)
      @group.respond_to? name
    end

    def method_missing(name,*args,&blk)
      @group.send name, *args, &blk
    end

    class Group
      def initialize
        @groups = {}
      end

      def [](group)
        @groups[group.to_sym] ||= Group.new
      end

      def []=(name,group)
        unless group.is_a? Group
          raise ArgumentError.new("Argument must be a group object")
        end
        @groups[name.to_sym] = group
      end

      def service(name,&blk)
        service_object = nil
        define_singleton_method name do
          service_object ||= blk.call
        end
      end

      def lookup(name)
        *groups, service = name.split(':')
        groups.inject(self) {|g,n|
          g[n.to_sym]
        }.send service
      end
    end
  end
end
