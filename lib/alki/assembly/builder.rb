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
        @load_mode = :direct
        @primary_config = 'assembly'
      end

      attr_reader :config_dir, :assembly_name, :definition

      def self.build(opts={},&blk)
        new.build(opts,&blk)
      end

      def build(opts={},&blk)
        @load_mode = opts[:load_mode] if opts[:load_mode]
        build_assembly blk if blk
        @primary_config = opts[:primary_config] if opts[:primary_config]
        set_assembly_name opts[:name] if opts[:name]
        setup_project_assembly opts[:project_assembly] if opts[:project_assembly]
        if opts[:config_dir]
          context = if opts[:project_assembly]
            File.dirname opts[:project_assembly]
          else
            Dir.pwd
          end
          @config_dir = File.expand_path opts[:config_dir], context
        end
        register_config_directory if @config_dir
        if blk
          build_assembly blk
        else
          load_assembly_file
        end
        build_empty_assembly unless definition
        build_class
      end

      def setup_project_assembly(path)
        root = Alki::Support.find_root(path) do |dir|
          File.exists?(File.join(dir,'config',"#{@primary_config}.rb")) ||
            File.exists?(File.join(dir,'Gemfile')) ||
            !Dir.glob(File.join(dir,'*.gemspec')).empty?
        end
        if root
          unless @assembly_name
            lib_dir = File.join(root,'lib')
            name = Alki::Support.path_name path, lib_dir
            unless name
              raise "Can't auto-detect name of assembly"
            end
            set_assembly_name name
          end

          unless @config_dir
            config_dir = File.join(root,'config')
            @config_dir = config_dir if File.exists? config_dir
          end
        end
      end

      def set_assembly_name(name)
        @assembly_name = name
      end

      def config_prefix
        unless @assembly_name
          raise "Can't use config directory without a name"
        end
        File.join(@assembly_name,'assembly_config')
      end

      def register_config_directory
        Alki::Loader.register @config_dir, builder: 'alki/dsls/assembly', name: config_prefix, **dsl_opts
      end

      def load_assembly_file
        if @config_dir
          @definition = File.join(config_prefix,@primary_config)
          true
        end
      end

      def build_empty_assembly
        build_assembly ->{}
      end

      def build_assembly(blk)
        @definition = Alki::Dsl.build('alki/dsls/assembly', dsl_opts, &blk)
      end

      def dsl_opts
        opts = {}
        if @assembly_name
          opts[:assembly_name] = @assembly_name
          if @config_dir
            opts[:config_dir] = @config_dir
            opts[:prefix] = config_prefix
          end
        end
        opts
      end

      def build_class
        definition = @definition
        name = @assembly_name
        load_class = if @load_mode == :require
          ->{ name }
        else
          ->{ self }
        end
        Alki::ClassBuilder.build(
          prefix: '',
          name: @assembly_name,
          class_modules: [Alki::Assembly],
          type: :module,
          class_methods: {
            assembly_name: {
              body: ->{
                name
              }
            },
            definition: {
              body: ->{
                Alki.load definition
              }
            },
            load_class: {
              body: load_class
            }
          }
        )
      end
    end
  end
end
