module Alki
  module Assembly
    class Instance
      def initialize(executor)
        @executor = executor
      end

      def root
        @root ||= @executor.call []
      end

      def respond_to_missing?(name,include_all)
        root.respond_to? name
      end

      def method_missing(name,*args,&blk)
        root.send name, *args, &blk
      end
    end
  end
end
