require 'alki/execution/context_class_builder'
require 'alki/execution/cache_entry'
require 'thread'

module Alki
  InvalidPathError = Class.new(StandardError)
  module Assembly
    class Executor
      def initialize(assembly,overlays)
        @assembly = assembly
        @overlays = overlays
        @data = {}
        @semaphore = Monitor.new
        clear
      end

      def clear
        @lookup_cache = {}
        @call_cache = {}
        @context_cache = {}
        @processed_overlays = false
      end

      def call(path,*args,&blk)
        execute({},path,args,blk)
      end

      def execute(meta,path,args,blk)
          cache_entry = @call_cache[path]
          if cache_entry
            if cache_entry.status == :building
              raise "Circular element reference found"
            end
          else
            @semaphore.synchronize do
              cache_entry = @call_cache[path]
              unless cache_entry
                cache_entry = @call_cache[path] = Alki::Execution::CacheEntry.new
                action = lookup(path)
                if action[:build]
                  build_meta = meta.merge(building: path.join('.'))
                  build_action = action[:build].merge(scope: action[:scope],modules: action[:modules])
                  call_value(*process_action(build_action),build_meta,[action])
                end
                cache_entry.finish *process_action(action)
              end
            end
          end
        call_value(cache_entry.type,cache_entry.value,meta,args,blk)
      end

      private

      def process_overlays
        unless @processed_overlays
          @processed_overlays = true
          @data[:overlays] = {}
          @overlays.each do |(from,info)|
            target = canonical_path(from,info.target) or
              raise InvalidPathError.new("Invalid overlay target #{info.target.join('.')}")
            overlay = canonical_path(from,info.overlay) or
              raise InvalidPathError.new("Invalid overlay path #{info.overlay.join('.')}")
            (@data[:overlays][target]||=[]) << [overlay,info.args]
          end
        end
      end

      def lookup(path)
        process_overlays
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


      def canonical_path(from,path)
        scope = lookup(from)[:full_scope]
        path.inject(nil) do |p,elem|
          scope = lookup(p)[:scope] if p
          scope[elem]
        end
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
