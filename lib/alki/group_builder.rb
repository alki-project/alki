require 'alki/group_dsl'
require 'alki/dsl_builder'

module Alki
  class GroupBuilder
    def self.build(loader,obj = {},&dsl)
      Alki::GroupBuilder.new(loader).build(obj,&dsl)
      obj
    end

    def initialize(loader)
      @loader = loader
      @builder = Alki::DslBuilder.new(self)
    end

    def new_dsl(obj)
      GroupDsl.new(obj,loader: @loader, group_builder: @builder)
    end

    def build(group={},&dsl)
      @builder.build(group,&dsl)
      group
    end
  end
end