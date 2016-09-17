require 'alki/package_executor'
require 'alki/package_processor'

module Alki
  class Package
    def initialize(package_definition)
      @def = package_definition
      @cache = {}
    end

    def root
      @root ||= __executor__.call @def, @cache, []
    end

    def package_definition
      @def
    end

    def respond_to_missing?(name,include_all)
      root.respond_to? name
    end

    def method_missing(name,*args,&blk)
      root.send name, *args, &blk
    end

    private

    def __executor__
      @executor ||= Alki::PackageExecutor.new Alki::PackageProcessor.new
    end
  end
end