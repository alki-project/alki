require 'alki/package'
require 'alki/loader'
require 'alki/group_builder'

module Alki
  class StandardPackage < Package
    def initialize(root_dir)
      @root_dir = root_dir
      loader = Alki::Loader.new(File.join(root_dir,'config'))
      builder = Alki::GroupBuilder.new loader
      pkg = builder.build &loader.load('package')
      loader_proc = ->() { loader }
      builder.build pkg do
        service :loader, &loader_proc
      end
      super pkg
    end
  end
end