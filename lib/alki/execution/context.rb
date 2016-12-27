require 'alki/execution/reference'
module Alki
  module Execution
    class Context
      def initialize(executor,meta)
        @__executor__ = executor
        @__meta__ = meta
      end

      private

      def __reference__(path,args,blk)
        Reference.new(@__executor__,@__meta__,path,args,blk)
      end

      def __execute__(path,args,blk)
        ref = __reference__ path, args, blk
        if respond_to?(:__process_reference__,true)
          __process_reference__ ref
        else
          ref.call
        end
      end
    end
  end
end
