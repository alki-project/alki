require 'delegate'
require 'concurrent'
require 'alki/support'
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
          if @obj
            @lock.with_write_lock do
              @needs_load = true
              @version+=1
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

      private

      def __load__
        @lock.with_write_lock do
          @needs_load = false
          @obj.__unload__ if @obj.respond_to?(:__unload__)
          InstanceBuilder.build @assembly_module, @overrides do |instance,executor|
            @obj = instance
            @executor = executor
            self
          end
        end
      end
    end
  end
end
