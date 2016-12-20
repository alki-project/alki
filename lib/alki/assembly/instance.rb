require 'delegate'
require 'alki/support'

module Alki
  module Assembly
    class Instance < Delegator
      def initialize(assembly_module,args)
        @assembly_module = assembly_module
        @args = args
      end

      def __reload__
        if @obj.respond_to? :__reload__
          did_something = @obj.__reload__
        end
        if did_something != false && @obj
          @obj = nil
          did_something = true
        end
        if did_something
          GC.start
        end
        !!did_something
      end

      def __setobj__(obj)
        @obj = obj
      end

      def __getobj__
        unless @obj
          Alki::Support.load_class(@assembly_module).raw_instance self, *@args
        end
        @obj
      end
    end
  end
end
