module Alki
  module Execution
    class Reference
      attr_accessor :instance, :meta, :path, :args, :blk
      def initialize(instance,meta,path,args,blk)
        @instance = instance
        @meta = meta
        @path = path
        @args = args
        @blk = blk
      end

      def executor
        @instance.__executor__
      end

      def call
        executor.execute @meta, @path, @args, @blk
      end
    end
  end
end
