module Alki
  module Execution
    class Reference
      attr_accessor :executor, :meta, :path, :args, :blk
      def initialize(executor,meta,path,args,blk)
        @executor = executor
        @meta = meta
        @path = path
        @args = args
        @blk = blk
      end

      def call
        @executor.execute @meta, @path, @args, @blk
      end
    end
  end
end
