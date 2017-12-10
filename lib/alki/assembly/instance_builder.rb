require 'alki/assembly/types'
require 'alki/override_builder'
require 'alki/assembly/meta/overlay'
require 'alki/overrides'
require 'ice_nine'

module Alki
  module Assembly
    module InstanceBuilder
      class << self
        def build(executor, assembly,overrides,&instance_wrapper)
          assembly = Alki.load(assembly)

          overrides = inject_assembly_instance overrides, instance_wrapper

          executor.root = Types.build :assembly, assembly.root, overrides.root
          executor.meta = IceNine.deep_freeze(assembly.meta.dup.append! overrides.meta)

          executor.call [:assembly_instance]
        end

        private
        
        def inject_assembly_instance(overrides,instance_wrapper)
          root = overrides.root.dup
          root.children = root.children.merge(assembly_instance: assembly_instance)
          meta = wrap_assembly_instance(overrides.meta,instance_wrapper)
          Overrides.new(root,meta)
        end

        def assembly_instance
          Types.build(:service,-> { root })
        end

        def wrap_assembly_instance(meta,wrapper)
          meta.dup.add Meta::Overlay.new(
            :value,
            [:assembly_instance],
            wrapper,
            []
          )
        end
      end
    end
  end
end
