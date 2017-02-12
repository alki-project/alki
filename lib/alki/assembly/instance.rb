require 'delegate'
require 'concurrent'
require 'alki/support'

module Alki
  module Assembly
    class Instance < Delegator
      def initialize(assembly_module,args)
        @assembly_module = assembly_module
        @args = args
        @version = 0
      end

      def __reload__
        if @obj.respond_to? :__reload__
          did_something = @obj.__reload__
        end
        if did_something != false && @obj
          __setobj__ nil
          did_something = true
        end
        if did_something
          GC.start
        end
        !!did_something
      end

      def __setobj__(obj)
        @version += 1
        @obj = obj
      end

      def __version__
        @version
      end

      def __getobj__
        unless @obj
          # Will call __setobj__
          Alki.load(@assembly_module).raw_instance self, *@args
        end
        @obj
      end
    end
  end
end
