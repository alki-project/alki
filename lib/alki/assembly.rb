require 'alki/assembly_executor'

module Alki
  module Assembly
    def new
      Alki::Assembly::Instance.new assembly, load_path: config_root
    end

    def assembly
      self.assembly_class.assembly
    end

    def root
      self.assembly_class.root
    end

    class Instance
      def initialize(assembly,opts={})
        @assembly = assembly
        @cache = {}
        @opts = opts
      end

      def root
        @root ||= __executor__.call @assembly, @cache, []
      end

      def respond_to_missing?(name,include_all)
        root.respond_to? name
      end

      def method_missing(name,*args,&blk)
        root.send name, *args, &blk
      end

      private

      def __executor__
        @executor ||= Alki::AssemblyExecutor.new @opts
      end
    end
  end
end