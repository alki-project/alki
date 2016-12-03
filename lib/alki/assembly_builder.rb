require 'alki/assembly'
require 'alki/class_builder'
require 'alki/dsl'
require 'alki/support'

module Alki
  class AssemblyBuilder
    def initialize
      @assembly_options = {}
      @assembly_name = nil
      @definition = nil
    end

    attr_reader :assembly_options, :assembly_name, :definition

    def self.build(opts={},&blk)
      new.build(opts,&blk)
    end

    def build(opts={},&blk)
      build_assembly blk if blk
      set_config_directory opts[:config_dir] if opts[:config_dir]
      set_assembly_name opts[:name] if opts[:name]
      setup_project_assembly opts[:project_assembly] if opts[:project_assembly]
      load_assembly_file opts[:primary_config] unless definition
      build_empty_assembly unless definition
      build_class
    end

    def setup_project_assembly(path)
      root = Alki::Support.find_root(path) do |dir|
        File.exists?(File.join(dir,'config','assembly.rb')) ||
          File.exists?(File.join(dir,'Gemfile')) ||
          !Dir.glob(File.join(dir,'*.gemspec')).empty?
      end
      if root
        unless @assembly_options[:load_path]
          config_dir = File.join(root,'config')
          set_config_directory config_dir if File.exists? config_dir
        end

        unless @assembly_name
          lib_dir = File.join(root,'lib')
          name = Alki::Support.path_name path, lib_dir
          unless name
            raise "Can't auto-detect name of assembly"
          end
          set_assembly_name name
        end
      end
    end

    def set_assembly_name(name)
      @assembly_name = name
    end

    def set_config_directory(config_dir)
      Alki::Dsl.register_dir config_dir, 'alki/dsls/assembly', {config_dir: config_dir}
      @assembly_options[:load_path] = config_dir
    end

    def load_assembly_file(name = nil)
      name ||= 'assembly'
      if @assembly_options[:load_path]
        assembly_config_path = File.join(@assembly_options[:load_path],"#{name}.rb")
        if File.exists? assembly_config_path
          @definition = Alki::Dsl.load(assembly_config_path)[:class]
          true
        end
      end
    end

    def build_empty_assembly
      build_assembly ->{}
    end

    def build_assembly(blk)
      @definition = Alki::Dsl.build('alki/dsls/assembly', &blk)[:class]
    end

    def build_class
      assembly_options = @assembly_options
      definition = @definition
      Alki::ClassBuilder.build(
        prefix: '',
        name: @assembly_name,
        class_modules: [Alki::Assembly],
        type: :module,
        class_methods: {
          definition: {
            body: ->{
              definition
            }
          },
          assembly_options: {
            body: ->{ assembly_options }
          }
        }
      )
    end
  end
end