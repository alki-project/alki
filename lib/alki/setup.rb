require 'alki/base'
module Alki
  @apps = {}
  def self.app
    old_dir = caller_locations(1,1)[0].absolute_path
    dir = File.dirname(old_dir)
    until dir == old_dir || File.exists?(File.join(dir,'Gemfile'))
      old_dir = dir
      dir = File.dirname(old_dir)
    end
    if dir == old_dir
      raise "Couldn't find app root"
    end
    @apps[dir] ||= Alki::StandardApplication.new dir
  end
end