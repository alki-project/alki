require 'delegate'
require 'concurrent'
require 'alki/support'
require 'concurrent'

module Alki
  module Assembly
    class Instance < Delegator
      def initialize(assembly_module,args)
        @assembly_module = assembly_module
        @args = args
        @version = 0
        @needs_load = true
        @lock = Concurrent::ReentrantReadWriteLock.new
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

      def __getobj__
        @lock.with_read_lock do
          __load__ if @needs_load
          @obj
        end
      end

      private

      def __load__
        # Calls __setobj__
        @lock.with_write_lock do
          @needs_load = false
          @obj.__unload__ if @obj.respond_to?(:__unload__)
          Alki.load(@assembly_module).raw_instance *@args do |obj|
            @obj = obj
            self
          end
        end
      end
    end
  end
end
