require 'alki/settings'

module Alki
  class Application
    attr_reader :settings

    def configure(&blk)
      self.instance_exec(&blk)
    end

    def initialize(settings={},root = Settings.new)
      unless root.is_a? Settings
        raise ArgumentError.new("Argument must be a settings object")
      end
      @group = root
      @settings = settings
      @current_group = @group
    end

    def root
      @group
    end
    alias_method :root_group, :root

    def group(name,new_group=nil)
      if block_given?
        unless @current_group[name]
          @current_group.set name, Settings.new
        end
        with_group(@current_group[name]) do
          yield
        end
      elsif new_group
        unless new_group.is_a? Settings
          raise ArgumentError.new("Argument must be a settings object")
        end
        @current_group.set name, new_group
      end
    end

    def service(name)
      group = @current_group
      @current_group.set(name) do
        with_group(group) do
          yield
        end
      end
    end

    def factory(name,&blk)
      group = @current_group
      @current_group.set_proc(name) do |*args|
        with_group(group) do
          yield *args
        end
      end
    end

    def with_group(group)
      old_group = @current_group
      @current_group = group
      yield.tap do
        @current_group = old_group
      end
    end

    def lookup(name)
      *groups, service = name.split('.')
      groups.inject(root) {|g,n|
        g[n.to_sym]
      }.send service
    end

    def respond_to_missing?(name,include_private = true)
      @current_group.respond_to? name or
        root.respond_to? name
    end

    def method_missing(name,*args,&blk)
      if @current_group.respond_to? name
        @current_group
      else
        root
      end.send name, *args, &blk
    end
  end
end
