require 'alki/executor'
require 'alki/override_builder'
require 'alki/dsls/assembly'

module Alki
  module Assembly
    def new(overrides={},&blk)
      overrides_info = OverrideBuilder.build(overrides,&blk)
      assembly = Alki::AssemblyTypes::Mount.new(root, overrides_info[:root])

      Alki::Assembly::Instance.new(assembly, overlays+overrides_info[:overlays])
    end

    def root
      self.definition.root
    end

    def overlays
      self.definition.overlays
    end

    class Instance
      def initialize(assembly,overlays)
        @executor = Alki::Executor.new assembly, overlays
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
