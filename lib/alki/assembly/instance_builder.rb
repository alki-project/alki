require 'alki/assembly/types'
require 'alki/assembly/executor'
require 'alki/override_builder'
require 'alki/assembly/meta/overlay'
require 'alki/overrides'
require 'ice_nine'

module Alki
  module Assembly
    module InstanceBuilder
      class << self
        def build(assembly,overrides,&instance_wrapper)
          assembly = Alki.load(assembly)

          overrides = inject_assembly_instance overrides, instance_wrapper

          root = Types.build :assembly, assembly.root, overrides.root
          meta = assembly.meta+overrides.meta

          IceNine.deep_freeze meta
          executor = Executor.new(root, meta)

          executor.call [:assembly_instance]
        end

        private

        def inject_assembly_instance(overrides,wrapper)
          root = overrides.root.dup
          root.children = root.children.merge(assembly_instance: assembly_instance)
          meta = overrides.meta + [wrap_assembly_instance(wrapper)]
          Overrides.new(root,meta)
        end

        def assembly_instance
          Types.build(:service,-> { root })
        end

        def wrap_assembly_instance(wrapper)
          [[],Meta::Overlay.new(
            :value,
            [:assembly_instance],
            -> obj { wrapper.call obj },
            []
          )]
        end
      end
    end
  end
end
