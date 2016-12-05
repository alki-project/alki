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

    def group(res)
      proc = -> (name,*args,&blk) {
        call res.pkg, res.cache, res.elem[:scope][name], *args, &blk
      }
      group = create_context(GroupContext,res)
      -> { group }
    end

    def with_scope_context(res,blk = nil)
      methods = {
        __call__: { body: (blk || res.elem[:block])}
      }
      yield create_context(ValueContext,res,methods)
    end

    def create_context(super_class,res,methods={})
      executor = self

      res.elem[:scope].keys.each do |meth|
        methods[meth] = {
          body: ->(*args,&blk) {
            executor.call res.pkg, res.cache, res.elem[:scope][meth], *args, &blk
          }
        }
      end
      context_class = Alki::ClassBuilder.build(
        super_class: super_class,
        instance_methods: methods
      )
      context_class.new
    end

    class Context
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
        Alki::ServiceDelegator.new assembly, path
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