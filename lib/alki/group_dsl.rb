require 'alki/util'

module Alki
  class GroupDsl
    def initialize(root,group_builder:,loader:)
      @root = root
      @group_builder = group_builder
      @loader = loader
    end

    def dsl_methods
      [:set,:service,:factory,:load,:import,:group,:overlay,:clear_overlays]
    end

    def set(name,value=nil,&blk)
      service name, &(blk || -> { value })
    end

    def service(name,&blk)
      name = name.to_sym
      @root[name] = {
        type: :service,
        block: blk
      }
    end

    def factory(name,&blk)
      name = name.to_sym
      @root[name] = {
        type: :factory,
        block: blk
      }
    end

    def import(name)
      instance_exec &@loader.load(name.to_s)
    end

    def load(name)
      group(name.to_sym) do
        import(name)
      end
    end

    def package(name,pkg,klass=nil,&blk)
      if pkg.is_a? String
        require pkg
        if klass == nil
          pkg = Alki::Util.classify(pkg)
        else
          pkg = klass
        end
      end
      if pkg.is_a? Class
        pkg = pkg.new
      end
      if pkg.response_to? :package_definition
        pkg = pkg.package_definition
      end
      unless pkg.is_a? Hash
        raise "Invalid package: #{pkg.inspect}"
      end
      name = name.to_sym
      overrides = {}
      @group_builder.build(overrides,&blk) if blk
      overrides[:original] = {
        type: :package,
        children: pkg,
        overrides: {}
      }
      @root[name] = {
        type: :package,
        children: pkg,
        overrides: overrides
      }
    end

    def group(name,&blk)
      name = name.to_sym
      children = {}
      @group_builder.build(children,&blk)
      @root[name] = {
        type: :group,
        children: children
      }
    end

    def overlay(&blk)
      @root['overlays'] ||= []
      @root['overlays'] << blk
    end

    def clear_overlays
      @root['overlays'] ||= []
      @root['overlays'] << :clear
    end
  end
end
