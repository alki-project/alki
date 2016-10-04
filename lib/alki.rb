module Alki
  def self.create_package!(name=nil,root=nil)
    require 'alki/util'
    require 'alki/standard_package'

    if !root
      root = Alki::Util.find_pkg_root(caller_locations(1, 1)[0].absolute_path)
    end
    if !name
      path = caller_locations(1,1)[0].absolute_path
      lib_dir = File.join(root,'lib','')
      unless path.start_with?(lib_dir) && path.end_with?('.rb')
        raise "Can't auto-detect name of package"
      end
      name = path[lib_dir.size..-4]
    end
    unless name =~ /[A-Z]/
      name = Alki::Util.classify(name)
    end
    klass = Class.new(Alki::StandardPackage)
    klass.send :define_method, :initialize do
      super root
    end

    mod = Module.new
    mod.const_set :Package, klass
    mod.send :define_singleton_method, :new do
      klass.new
    end

    Alki::Util.create_class(name,mod)
  end
end