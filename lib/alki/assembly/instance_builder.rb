require 'alki/assembly/types'
require 'alki/executor'
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
          executor = Executor.new

          overrides = inject_assembly_instance overrides, instance_wrapper, executor

          executor.root = Types.build :assembly, assembly.root, overrides.root
          executor.meta = IceNine.deep_freeze(assembly.meta+overrides.meta)

          executor.call [:assembly_instance]
        end

        private
        
        def inject_assembly_instance(overrides,instance_wrapper,executor)
          root = overrides.root.dup
          root.children = root.children.merge(assembly_instance: assembly_instance)
          meta = overrides.meta + [wrap_assembly_instance(instance_wrapper,executor)]
          Overrides.new(root,meta)
        end

        def assembly_instance
          Types.build(:service,-> { root })
        end

        def wrap_assembly_instance(wrapper,executor)
          [[],Meta::Overlay.new(
            :value,
            [:assembly_instance],
            -> obj { wrapper.call obj, executor },
            []
          )]
        end
      end
    end
  end
end
