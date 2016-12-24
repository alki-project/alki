module Alki
  module Assembly
    class Type
      def index(*args)
        handler(args).index
      end

      def output(*args)
        handler(args).output
      end

      private

      def handler(args)
        self.class::Handler.new(self,*args)
      end
    end
  end
end
