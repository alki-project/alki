require 'alki/support'
require 'alki/assembly'
require 'alki/class_builder'
require 'alki/dsl'

module Alki
  def self.create_assembly!(name=nil,root=nil)
    if !root
      root = Alki::Support.find_root(caller_locations(1, 1)[0].absolute_path) do |dir|
        File.exists?(File.join(dir,'config','assembly.rb'))
      end
    end
    if !name
      path = caller_locations(1,1)[0].absolute_path
      lib_dir = File.join(root,'lib','')
      unless path.start_with?(lib_dir) && path.end_with?('.rb')
        raise "Can't auto-detect name of assembly"
      end
      name = path[lib_dir.size..-4]
    end
    config_root = File.join(root,'config')
    Alki::ClassBuilder.build(
      name: name,
      class_modules: [Alki::Assembly],
      type: :module,
      class_methods: {
        assembly_class: {
          body: ->{
            @assembly_class ||= Alki::Dsl.load(File.join(config_root,'assembly.rb'))[:class]
          }
        },
        config_root: {
          body: ->{ config_root }
        }
      }
    )
    Alki::Dsl.register_dir config_root, 'alki/dsls/assembly', prefix: File.join(name,'assembly')
  end
end