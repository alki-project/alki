require 'alki/execution/context_class_builder'
require 'alki/execution/cache_entry'
require 'thread'

module Alki
  InvalidPathError = Class.new(StandardError)
  module Assembly
    class Executor
      def initialize(assembly,meta)
        @assembly = assembly
        @meta = meta
        @data = {}
        @semaphore = Monitor.new
        @lookup_cache = {}
        @call_cache = {}
        @context_cache = {}
        @processed_meta = false
      end

      def synchronize
        @semaphore.synchronize do
          yield
        end
      end

      def call(path,*args,&blk)
        execute({},path,args,blk)
      end

      def execute(meta,path,args,blk)
        cache_entry = @call_cache[path]
        if cache_entry
          if cache_entry.status == :building
            raise "Circular element reference found: #{path.join(".")}"
          end
        else
          synchronize do
            cache_entry = @call_cache[path]
            unless cache_entry
              cache_entry = @call_cache[path] = Alki::Execution::CacheEntry.new
              action = lookup(path)
              if action[:build]
                build_meta = meta.merge(building: path.join('.'))
                build_meta.merge!(action[:meta]) if action[:meta]
                build_action = action[:build].merge(scope: action[:scope],modules: action[:modules])
                call_value(*process_action(build_action),build_meta,[action])
              end
              cache_entry.finish *process_action(action)
            end
          end
        end
        call_value(cache_entry.type,cache_entry.value,meta,args,blk)
      end

      def canonical_path(from,path)
        from_elem = lookup(from)
        scope = from_elem[:full_scope] || from_elem[:scope]
        path.inject(nil) do |p,elem|
          scope = lookup(p)[:scope] if p
          scope[elem]
        end
      end

      private

      def process_meta
        unless @processed_meta
          @processed_meta = true
          @data[:overlays] = {}
          @meta.each do |(from,type,info)|
            case type
              when :overlay then process_overlay from, info
            end
          end
        end
      end

      def process_overlay(from,info)
        target = canonical_path(from,info.target) or
          raise InvalidPathError.new("Invalid overlay target #{info.target.join('.')}")
        overlay = info.overlay
        if overlay.is_a?(Array)
          overlay = canonical_path(from,info.overlay) or
            raise InvalidPathError.new("Invalid overlay path #{info.overlay.join('.')}")
        end
        (@data[:overlays][target]||=[]) << [overlay, info.args]
      end

      def lookup(path)
        process_meta
        @lookup_cache[path] ||= lookup_elem(path).tap do |elem|
          unless elem
            raise InvalidPathError.new("Invalid path #{path.inspect}")
          end
        end
      end

      def lookup_elem(path)
        data = @data.dup
        elem = @assembly
        path.each do |key|
          elem = elem.index data, key
          return nil unless elem
        end
        elem.output data
      end

      def process_action(action)
        if action.key?(:value)
          [:value,action[:value]]
        elsif action[:proc]
          if action[:scope]
            [:class,context_class(action)]
          else
            [:proc,action[:proc]]
          end
        end or raise "Invalid action"
      end

      def call_value(type,value,meta,args=[],blk=nil)
        case type
          when :value then value
          when :proc then proc.call *args, &blk
          when :class then value.new(self,meta).__call__ *args, &blk
        end
      end

      def context_class(action)
        desc = {
          scope: action[:scope],
          body: action[:proc],
          modules: action[:modules],
          methods: action[:methods]
        }
        @context_cache[desc] ||= Alki::Execution::ContextClassBuilder.build(desc)
      end
    end
  end
end
