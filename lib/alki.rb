require 'alki/dsl'
require 'alki/assembly_builder'

module Alki
  class << self
    def project_assembly!(opts={},&blk)
      opts[:project_assembly] ||= caller_locations(1,1)[0].absolute_path
      AssemblyBuilder.build(opts,&blk)
    end

    alias_method :create_assembly!, :project_assembly!

    def create_assembly(opts={},&blk)
      AssemblyBuilder.build(opts,&blk)
    end
  end
end