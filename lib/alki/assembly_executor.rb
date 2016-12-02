require 'alki/service_delegator'
require 'alki/overlay_delegator'
require 'alki/class_builder'

module Alki
  class AssemblyExecutor
    class Resource
      attr_reader :pkg, :cache, :elem
      def initialize(pkg,cache,elem)
        @pkg = pkg
        @cache = cache
        @elem = elem
      end

      def with_elem(elem)
        Resource.new @pkg, @cache, elem
      end
    end

    def initialize(data={})
      @data = data
    end

    def call(assembly,cache,path,*args,&blk)
      unless cache[path]
        elem = assembly.lookup path, @data
        raise "Path not found: #{path.join('.')}" unless elem
        res = Resource.new assembly, cache, elem
        cache[path] = case elem[:type]
          when :value
            value res, path
          when :group
            group res
        end
      end
      cache[path].call *args, &blk
    end

    def value(res,path)
      evaluator = -> (value_block,*args,&blk) {
        with_scope_context(res,value_block) do |ctx|
          val = ctx.__call__(*args,&blk)
          if res.elem[:overlays]
            val = apply_overlays res, path, val
          end
          val
        end
      }
      res.elem[:block].call evaluator
    end

    def service(res,path)
      with_scope_context(res) do |ctx,blk|
        svc = apply_overlays res, path, ctx.instance_exec(&blk)
        -> { svc }
      end
    end

    def apply_overlays(res,path,obj)
      res.elem[:overlays].inject(obj) do |obj,overlay_elem|
        unless res.cache[overlay_elem[:block]]
          with_scope_context(res.with_elem(overlay_elem)) do |ctx|
            res.cache[overlay_elem[:block]] = ctx.__call__
          end
        end
        local_path = path[overlay_elem[:scope][:root].size..-1].join('.')
        Alki::OverlayDelegator.new local_path,obj, res.cache[overlay_elem[:block]]
      end
    end

    def factory(res)
      with_scope_context(res) do |ctx,blk|
        factory = ctx.instance_exec(&blk)
        -> (*args,&blk) {
          factory.call *args, &blk
        }
      end
    end

    def group(res)
      proc = -> (name,*args,&blk) {
        call res.pkg, res.cache, res.elem[:scope][name], *args, &blk
      }
      group = GroupContext.new(proc,res.elem[:scope].keys)
      -> { group }
    end

    def with_scope_context(res,blk = nil)
      proc = -> (name,*args,&blk) {
        call res.pkg, res.cache, res.elem[:scope][name], *args, &blk
      }

      context_class = Alki::ClassBuilder.build(
        super_class: ValueContext,
        instance_methods: {
          __call__: { body: (blk || res.elem[:block])}
        }
      )

      yield context_class.new(proc, res.elem[:scope].keys)
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

    class ValueContext < Context
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
        Alki::ServiceDelegator.new pkg, path
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