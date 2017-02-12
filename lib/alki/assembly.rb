require 'alki/override_builder'
require 'alki/assembly/instance'
require 'alki/assembly/executor'
require 'alki/assembly/meta/overlay'
require 'alki/overlay_info'
require 'ice_nine'

module Alki
  module Assembly
    def new(overrides={},&blk)
      Instance.new load_class, [overrides, blk]
    end

    def raw_instance(instance,overrides,blk)
      overrides_info = OverrideBuilder.build(overrides,&blk)
      override_root = overrides_info[:root] || build(:group)

      assembly = build :assembly, root, override_root
      update_instance_overlay = [[],Meta::Overlay.new(
        :value,
        [:assembly_instance],
        ->obj{instance.__setobj__ obj; instance},
        []
      )]
      all_meta = meta+overrides_info[:meta]+[update_instance_overlay]
      IceNine.deep_freeze all_meta
      executor = Executor.new(assembly, all_meta)

      override_root.children[:assembly_instance] = build(:service,->{ root })
      override_root.children[:assembly_executor] = build(:value,executor)

      executor.call [:assembly_instance]
    end

    def root
      self.definition.root
    end

    def meta
      self.definition.meta
    end

    private

    def build(type,*args)
      Alki.load("alki/assembly/types/#{type}").new *args
    end
  end
end
