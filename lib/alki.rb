require 'alki/assembly_builder'

module Alki
  def self.create_assembly!(opts={},&blk)
    opts[:path] ||= caller_locations(1,1)[0].absolute_path
    AssemblyBuilder.build(opts,&blk)
  end

  def self.create_assembly(opts={},&blk)
    AssemblyBuilder.build(opts,&blk)
  end
end