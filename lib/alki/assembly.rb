require 'alki/override_builder'
require 'alki/assembly/types/assembly'
require 'alki/assembly/instance'
require 'alki/assembly/executor'

module Alki
  module Assembly
    def new(overrides={},&blk)
      overrides_info = OverrideBuilder.build(overrides,&blk)
      assembly = Types::Assembly.new(root, overrides_info[:root])

      Instance.new(Executor.new(assembly, overlays+overrides_info[:overlays]))
    end

    def root
      self.definition.root
    end

    def overlays
      self.definition.overlays
    end
  end
end
