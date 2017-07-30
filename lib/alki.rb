require 'alki/dsl'
require 'alki/assembly/builder'

Alki::Assembly::Builder.build project_assembly: __FILE__, load_mode: :require

def Alki.project_assembly!(opts={},&blk)
  opts[:project_assembly] ||= caller_locations(1,1)[0].absolute_path
  opts[:load_mode] = :require
  Alki::Assembly::Builder.build(opts,&blk)
end

def Alki.create_assembly(opts={},&blk)
  Alki::Assembly::Builder.build(opts,&blk)
end

def Alki.singleton_assembly(opts={},&blk)
  Alki.create_assembly(opts,&blk).new
end
