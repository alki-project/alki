require 'alki/execution/context_class_builder'
require 'alki/execution/cache_entry'
require 'concurrent'
require 'alki/invalid_path_error'
require 'alki/circular_reference_error'

module Alki
  class Executor
    attr_accessor :root, :meta

    def initialize(instance)
      @semaphore = Concurrent::ReentrantReadWriteLock.new
      @lookup_cache = {}
      @call_cache = {}
      @context_cache = {}
      @data = nil
      @instance = instance
    end

    def lock
      @semaphore.with_write_lock do
        yield
      end
    end

    def call(path,*args,&blk)
      execute({},path,args,blk)
    end

    def lookup(path)
      @semaphore.with_read_lock do
        unless @lookup_cache[path]
          @semaphore.with_write_lock do
            @lookup_cache[path] = lookup_elem(path).tap do |elem|
              unless elem
                raise InvalidPathError.new("Invalid path #{path.inspect}")
              end
            end
          end
        end
        @lookup_cache[path]
      end
    end

    def canonical_path(from,path)
      from_elem = lookup(from)
      scope = from_elem[:scope]
      path.inject(nil) do |p,elem|
        scope = lookup(p)[:scope] if p
        scope[elem]
      end
    end

    def execute(meta,path,args,blk)
      type,value = nil,nil
      @semaphore.with_read_lock do
        cache_entry = @call_cache[path]
        if cache_entry
          if cache_entry == :building
            raise Alki::CircularReferenceError.new
          end
          type,value = cache_entry.type,cache_entry.value
        else
          @semaphore.with_write_lock do
            @call_cache[path] = :building
            type, value = build(path)
            @call_cache[path] = Alki::Execution::CacheEntry.finished type, value
          end
        end
      end
      call_value(type, value, meta, args, blk)
    rescue Alki::CircularReferenceError => e
      e.chain << path
      raise
    end

    private

    def build(path)
      action = lookup(path)
      if action[:build]
        build_meta = {building: path.join('.')}
        build_meta.merge!(action[:meta]) if action[:meta]
        build_action = action[:build].merge(scope: action[:scope], modules: action[:modules])
        call_value(*process_action(build_action), build_meta, [action])
      end
      process_action action
    end

    def data_copy
      unless @data
        @data = {}
        @meta.each do |from, meta|
          meta.process self, from, @data
        end
        IceNine.deep_freeze @data
      end
      @data.dup
    end

    def lookup_elem(path)
      data = data_copy
      elem = @root
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
        when :class then value.new(@instance,meta).__call__ *args, &blk
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
