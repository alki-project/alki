module Alki
  module Assembly
    class MetaList
      attr_reader :list

      def initialize(list = [])
        @list = list
      end

      def add(name=nil,meta)
        path = name ? [name.to_sym] : []
        @list << [path,meta]
        self
      end

      def prefix(*prefix)
        @list.each do |(path,_)|
          path.unshift *prefix
        end
        self
      end

      def append(*prefix, meta_list)
        append! *prefix, meta_list.dup
        self
      end

      def append!(*prefix, meta_list)
        @list.push *meta_list.prefix(*prefix).list
        self
      end

      def each
        enum_for(:each) unless block_given?
        @list.each do |(path,meta)|
          yield path, meta
        end
        self
      end

      def to_a
        @list.map do |(path,meta)|
          [path.dup,meta]
        end
      end

      def dup
        self.class.new to_a
      end
    end
  end
end
