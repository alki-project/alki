require 'alki/dsls/assembly'

module Alki
  module OverrideBuilder
    def self.build(override_hash=nil,&blk)
      if blk
        Alki::Dsls::AssemblyGroup.build(&blk)
      elsif override_hash && !override_hash.empty?
        { root: create_override_group(override_hash), overlays: [] }
      else
        { root: nil, overlays: [] }
      end
    end

    def self.create_override_group(overrides)
      unless overrides.empty?
        root = build_type(:group)
        overrides.each do |path,value|
          set_override root, *path.to_s.split('.'), value
        end
        root
      end
    end

    def self.set_override(root,*parent_keys,key,value)
      parent = parent_keys.inject(root) do |parent,key|
        parent.children[key.to_sym] ||= build_type(:group)
      end
      parent.children[key.to_sym] = build_type(:value, value)
    end

    def self.build_type(type,*args)
      Alki::Support.load_class("alki/assembly_types/#{type}").new *args
    end

  end
end
