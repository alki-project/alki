module Alki
  module Util
    def self.classify(str)
      str.split('/').map do |c|
        c.split('_').map{|n| n.capitalize }.join('')
      end.join('::')
    end

    def self.create_class(name,klass = Class.new)
      *ans, ln = name.to_s.split(/::/)
      parent = Object
      ans.each do |a|
        unless parent.const_defined? a
          parent.const_set a, Module.new
        end
        parent = parent.const_get a
      end

      parent.const_set ln, klass
    end

    def self.find_pkg_root(path)
      old_dir = File.absolute_path(path)
      dir = File.dirname(old_dir)
      until dir == old_dir || File.exists?(File.join(dir,'config','package.rb'))
        old_dir = dir
        dir = File.dirname(old_dir)
      end
      if dir == old_dir
        raise "Couldn't find app root"
      end
      dir
    end
  end
end