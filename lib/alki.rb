require 'alki/dsl'
require 'alki/assembly/builder'

module Alki
  class << self
    def project_assembly!(opts={},&blk)
      opts[:project_assembly] ||= caller_locations(1,1)[0].absolute_path
      Assembly::Builder.build(opts,&blk)
    end

    alias_method :create_assembly!, :project_assembly!

    def create_assembly(opts={},&blk)
      Assembly::Builder.build(opts,&blk)
    end
  end
end
