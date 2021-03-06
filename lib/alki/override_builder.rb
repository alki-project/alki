require 'alki/dsl'
require 'alki/overrides'
require 'alki/assembly/types'
require 'alki/assembly/meta_list'

module Alki
  module OverrideBuilder
    class << self
      def build(override_hash=nil,&blk)
        if blk
          data = Alki::Dsl.build('alki/dsls/assembly_group',&blk)
          Overrides.new data[:root], data[:meta]
        elsif override_hash && !override_hash.empty?
          Overrides.new create_override_group(override_hash), Alki::Assembly::MetaList.new
        else
          Overrides.new build_type(:group), Alki::Assembly::MetaList.new
        end
      end

      private

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
        parent = parent_keys.inject(root) do |group,parent_key|
          group.children[parent_key.to_sym] ||= build_type(:group)
        end
        parent.children[key.to_sym] = build_type(:value, value)
      end

      def build_type(type,*args)
        Assembly::Types.build(type,*args)
      end
    end
  end
end
