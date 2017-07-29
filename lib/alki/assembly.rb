require 'alki/assembly/instance'
require 'alki/override_builder'

module Alki
  module Assembly
    def new(override_values={},&override_blk)
      overrides = OverrideBuilder.build override_values, &override_blk
      Instance.new load_class, overrides
    end

    def root
      self.definition.root
    end

    def meta
      self.definition.meta
    end
  end
end
