require 'delegate'
require 'concurrent'
require 'alki/support'
require 'alki/executor'
require 'alki/assembly/instance_builder'

module Alki
  module Assembly
    class Instance < Delegator
      def initialize(assembly_module,overrides)
        @assembly_module = assembly_module
        @overrides = overrides
        @version = 0
        @needs_load = true
        @lock = Concurrent::ReentrantReadWriteLock.new
        @obj = nil
        @executor = nil
      end

      def __reload__
        @lock.with_read_lock do
          unless @needs_load
            @lock.with_write_lock do
              @version += 1
              @needs_load = true
            end
          end
        end
      end

      def __version__
        @lock.with_read_lock do
          @version
        end
      end

      def __executor__
        @lock.with_read_lock do
          __load__ if @needs_load
          @executor
        end
      end

      def __getobj__
        @lock.with_read_lock do
          __load__ if @needs_load
          @obj
        end
      end

      def to_s
        inspect
      end

      def inspect
        if @assembly_module.is_a?(Module)
          name = @assembly_module.name || 'AnonymousAssembly'
        else
          name = Alki::Support.classify(@assembly_module.to_s)
        end
        "#<#{name}:#{object_id}>"
      end

      def pretty_print(q)
        q.text(inspect)
      end
      private

      def __load__
        @lock.with_write_lock do
          @needs_load = false
          @obj.__unload__ if @obj.respond_to?(:__unload__)
          @executor = Executor.new(self)
          InstanceBuilder.build @executor,@assembly_module, @overrides do |instance|
            @obj = instance
            self
          end
        end
      end
    end
  end
end
