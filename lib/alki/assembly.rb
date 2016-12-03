require 'alki/assembly_executor'
require 'alki/dsls/assembly'

module Alki
  module Assembly
    def new(overrides={})
      Alki::Assembly::Instance.new create_assembly(overrides), self.assembly_options
    end

    def root
      self.definition.root
    end

    private

    def create_assembly(overrides={})
      config_dir = if assembly_options[:load_path]
        build_type :value, assembly_options[:load_path]
      else
        nil
      end

      build_type :assembly, root, config_dir, create_override_group(overrides)
    end


    def create_override_group(overrides)
      unless overrides.empty?
        root = build_type(:group)
        overrides.each do |path,value|
          set_override root, *path.to_s.split('.'), value
        end
        root
      end
    end

    def set_override(root,*parent_keys,key,value)
      parent = parent_keys.inject(root) do |parent,key|
        parent.children[key.to_sym] ||= build_type(:group)
      end
      parent.children[key.to_sym] = build_type(:value, value)
    end

    def build_type(type,*args)
      Alki::Support.load_class("alki/assembly_types/#{type}").new *args
    end

    class Instance
      def initialize(assembly,opts)
        @assembly = assembly
        @cache = {}
        @opts = opts
      end

      def root
        @root ||= __executor__.call @assembly, @cache, []
      end

      def respond_to_missing?(name,include_all)
        root.respond_to? name
      end

      def method_missing(name,*args,&blk)
        root.send name, *args, &blk
      end

      private

      def __executor__
        @executor ||= Alki::AssemblyExecutor.new @opts
      end
    end
  end
end