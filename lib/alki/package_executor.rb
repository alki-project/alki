require 'alki/service_delegator'
require 'alki/overlay_delegator'

module Alki
  class PackageExecutor
    def initialize(processor)
      @processor = processor
    end

    def call(pkg,cache,path,*args,&blk)
      elem = @processor.lookup(pkg,path)
      triple = [pkg,cache,elem]
      case elem[:type]
        when :service
          service triple, path, *args
        when :factory
          factory triple, path, *args, &blk
        when :group
          group triple, *args
      end
    end

    def service(triple,path)
      pkg,cache,elem = triple
      unless cache[path]
        with_scope_context(triple) do |ctx,blk|
          cache[path] = apply_overlays triple,path, ctx.instance_exec(&blk)
        end
      end
      cache[path]
    end

    def apply_overlays((pkg,cache,elem),path,obj)
      elem[:overlays].inject(obj) do |obj,overlay_elem|
        unless cache[overlay_elem[:block]]
          with_scope_context([pkg,cache,overlay_elem]) do |ctx,blk|
            cache[overlay_elem[:block]] = ctx.instance_exec(&blk)
          end
        end
        local_path = path[overlay_elem[:scope][:root].size..-1].join('.')
        Alki::OverlayDelegator.new local_path,obj, cache[overlay_elem[:block]]
      end
    end

    def factory(triple,path,*args,&blk)
      pkg,cache,elem = triple
      unless cache[path]
        with_scope_context(triple) do |ctx,blk|
          cache[path] = ctx.instance_exec(&blk)
        end
      end
      cache[path].call *args, &blk
    end

    def group((pkg,cache,elem))
      proc = -> (name,*args,&blk) {
        call pkg, cache, elem[:children][name], *args, &blk
      }

      GroupContext.new(proc,elem[:children].keys)
    end

    def with_scope_context((pkg,cache,elem))
      proc = -> (name,*args,&blk) {
        call pkg, cache, elem[:scope][name], *args, &blk
      }

      yield ServiceContext.new(proc,elem[:scope].keys), elem[:block]
    end

    class Context
      def initialize(executor,scope)
        @executor = executor
        @scope = scope
      end

      def respond_to_missing?(name,include_all)
        @scope.include? name
      end

      def method_missing(name,*args,&blk)
        if @scope.include? name
          @executor.call name, *args, &blk
        else
          super
        end
      end
    end

    class ServiceContext < Context
      def lookup(path)
        unless path.is_a?(String) or path.is_a?(Symbol)
          raise ArgumentError.new("lookup can only take Strings or Symbols")
        end
        path.to_s.split('.').inject(self) do |group,name|
          raise "Invalid lookup path" unless group.is_a? Context
          group.send name.to_sym
        end
      end

      def lazy(path)
        unless path.is_a?(String) or path.is_a?(Symbol)
          raise ArgumentError.new("lazy can only take Strings or Symbols")
        end
        Alki::ServiceDelegator.new root, path
      end
    end

    class GroupContext < Context
      def lookup(path)
        unless path.is_a?(String) or path.is_a?(Symbol)
          raise ArgumentError.new("lookup can only take Strings or Symbols")
        end
        path.to_s.split('.').inject(self) do |group,name|
          group.send name.to_sym
        end
      end
    end
  end
end