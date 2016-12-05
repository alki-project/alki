require 'alki/assembly_executor'
require 'alki/override_builder'
require 'alki/dsls/assembly'

module Alki
  module Assembly
    def new(overrides={},&blk)
      Alki::Assembly::Instance.new create_assembly(overrides,&blk), self.assembly_options
    end

    def root
      self.definition.root
    end

    private

    def create_assembly(overrides={},&blk)
      config_dir = if assembly_options[:load_path]
        Alki::Support.load_class("alki/assembly_types/value").new assembly_options[:load_path]
      else
        nil
      end

      Alki::Support.load_class("alki/assembly_types/assembly").new root, config_dir, OverrideBuilder.build(overrides,&blk)
    end

    class Instance
      def initialize(assembly,opts)
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