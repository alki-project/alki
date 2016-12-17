require 'alki/override_builder'
require 'alki/assembly/types/assembly'
require 'alki/assembly/types/group'
require 'alki/assembly/instance'
require 'alki/assembly/executor'

module Alki
  module Assembly
    def new(overrides={},&blk)
      overrides_info = OverrideBuilder.build(overrides,&blk)
      override_root = overrides_info[:root] || build(:group)

      assembly = build :assembly, root, override_root
      executor = Executor.new(assembly, overlays+overrides_info[:overlays])

      override_root.children[:assembly_instance] = build(:service,->{
        Instance.new(executor)
      })
      executor.call [:assembly_instance]
    end

    def build(type,*args)
      Alki::Support.load_class("alki/assembly/types/#{type}").new *args
    end

    def root
      self.definition.root
    end

    def overlays
      self.definition.overlays
    end
  end
end
