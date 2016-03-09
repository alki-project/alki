require 'alki/settings'
require 'alki/service_delegator'

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
      @stack = [@group]
    end

    def current_group
      @stack.last
    end

    def root
      @group
    end
    alias_method :root_group, :root

    def group(name,new_group=nil)
      if block_given?
        unless current_group[name]
          current_group.set name, Settings.new
        end
        with_group(current_group[name]) do
          yield
        end
      elsif new_group
        unless new_group.is_a? Settings
          raise ArgumentError.new("Argument must be a settings object")
        end
        current_group.set name, new_group
      end
    end

    def service(name)
      stack = @stack.dup
      current_group.set(name) do
        with_stack(stack) do
          yield
        end
      end
    end

    def factory(name,&blk)
      stack = @stack.dup
      current_group.set_proc(name) do |*args|
        with_stack(stack) do
          yield *args
        end
      end
    end

    def with_stack(stack)
      old_stack = @stack
      @stack = stack
      yield.tap do
        @stack = old_stack
      end
    end

    def with_group(group)
      @stack.push group
      yield.tap do
        @stack.pop
      end
    end

    def lookup(name)
      *groups, service = name.to_s.split('.')
      groups.inject(root) {|g,n|
        g[n.to_sym]
      }.send service
    end

    def delegate(path)
      ServiceDelegator.new self, path
    end

    def respond_to_missing?(name,include_private = true)
      @stack.reverse.any? do |group|
        group.respond_to? name
      end
    end

    def method_missing(name,*args,&blk)
      @stack.reverse.find do |group|
        group.respond_to? name
      end.send name, *args, &blk
    end
  end
end
