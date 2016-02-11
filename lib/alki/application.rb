require 'alki/settings'

module Alki
  class Application
    attr_reader :settings

    def configure(&blk)
      self.instance_exec(&blk)
    end

    def initialize(settings={},root_group = Settings.new)
      unless root_group.is_a? Settings
        raise ArgumentError.new("Argument must be a settings object")
      end
      @group = root_group
      @settings = settings
      @current_group = @group
    end

    def root_group
      @group
    end

    def group(name,new_group=nil)
      if block_given?
        unless @current_group[name]
          @current_group.set name, Settings.new
        end
        old_group = @current_group
        @current_group = @current_group[name]
        yield
        @current_group = old_group
      elsif new_group
        unless new_group.is_a? Settings
          raise ArgumentError.new("Argument must be a settings object")
        end
        @current_group.set name, new_group
      end
    end

    def service(name,&blk)
      @current_group.set(name,&blk)
    end

    def lookup(name)
      *groups, service = name.split('.')
      groups.inject(root_group) {|g,n|
        g[n.to_sym]
      }.send service
    end

    def respond_to_missing?(name,include_private = true)
      root_group.respond_to? name
    end

    def method_missing(name,*args,&blk)
      root_group.send name, *args, &blk
    end
  end
end
