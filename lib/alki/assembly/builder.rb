require 'alki/assembly'
require 'alki/class_builder'
require 'alki/dsl'
require 'alki/support'

module Alki
  module Assembly
    class Builder
      def initialize
        @config_dir = nil
        @assembly_name = nil
        @definition = nil
      end

      attr_reader :config_dir, :assembly_name, :definition

      def self.build(opts={},&blk)
        new.build(opts,&blk)
      end

      def build(opts={},&blk)
        build_assembly blk if blk
        if opts[:config_dir]
          context = if opts[:project_assembly]
            File.dirname opts[:project_assembly]
          else
            Dir.pwd
          end
          @config_dir = File.expand_path opts[:config_dir], context
        end
        set_assembly_name opts[:name] if opts[:name]
        setup_project_assembly opts[:project_assembly] if opts[:project_assembly]
        register_config_directory if @config_dir
        if blk
          build_assembly blk
        else
          load_assembly_file opts[:primary_config]
        end
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
          unless @config_dir
            config_dir = File.join(root,'config')
            @config_dir = config_dir if File.exists? config_dir
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

      def register_config_directory
        Alki::Dsl.register_dir @config_dir, 'alki/dsls/assembly', {config_dir: @config_dir}
      end

      def load_assembly_file(name = nil)
        name ||= 'assembly'
        if @config_dir
          assembly_config_path = File.join(@config_dir,"#{name}.rb")
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
        @definition = Alki::Dsl.build('alki/dsls/assembly', config_dir: @config_dir, &blk)[:class]
      end

      def build_class
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
          }
        )
      end
    end
  end
end
