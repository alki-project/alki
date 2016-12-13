require 'alki/execution/context_class_builder'
require 'alki/execution/cache_entry'

module Alki
  class Executor
    attr_accessor :call_cache, :context_cache
    def initialize(assembly,data={})
      @assembly = assembly
      @data = data
      @call_cache = {}
      @context_cache = {}
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
        action = @assembly.lookup(path,@data)
        cache_entry = @call_cache[path] = Alki::Execution::CacheEntry.new
        if action[:build]
          build_meta = meta.merge(building: path.join('.'))
          build_action = action[:build].merge(scope: action[:scope],modules: action[:modules])
          call_value(*process_action(build_action),build_meta,[action])
        end
        cache_entry.finish *process_action(action)
      end
      call_value(cache_entry.type,cache_entry.value,meta,args,blk)
    end

    private

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
