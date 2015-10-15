require 'alki/settings'
require 'alki/application'
require 'alki/loader'

module Alki
  class StandardApplication < Application
    def self.enter(root_dir,service)
      self.new(root_dir).send(service)
    end

    def initialize(root_dir, environment=nil)
      super Alki::Settings.new(environment)
      settings.set :root_dir, root_dir

      lib_path = File.join(root_dir,'lib')
      $LOAD_PATH << lib_path unless $LOAD_PATH.include? lib_path

      service :config_loader do
        Loader.new(File.expand_path('config',settings.root_dir))
      end
      configure &config_loader.load('services')
      settings.set :app, self
      settings.configure &config_loader.load('settings')
    end
  end
end