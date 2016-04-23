require 'bundler/setup'
require 'alki/base'
app = Alki::StandardApplication.new Bundler.root
Alki.define_singleton_method :app do
  app
end