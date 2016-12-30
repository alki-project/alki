Bundler.require(:test,:development)
require 'alki/dsl'

module Alki
  module Test
    def app_root
      Bundler.root
    end

    def lib_dir
      File.join app_root, 'lib'
    end

    def tests_root
      File.join app_root, 'test'
    end

    def fixtures_path
      File.join tests_root, 'fixtures'
    end

    def fixture_path(*fixture)
      File.join fixtures_path, *fixture
    end

    def load_fixture(*fixture)
      require fixture_path(*fixture)
    end

    extend self
  end
end

if defined? Minitest
  require 'minitest/autorun'
  class Minitest::Spec
    include Alki::Test
  end
end

if defined? RSpec
  require 'rspec/autorun'
  RSpec.configure do |config|
    config.include Alki::Test
  end
end

unless $LOAD_PATH.include? Alki::Test.lib_dir
  $LOAD_PATH.unshift Alki::Test.lib_dir
end

test_helper = File.join(Alki::Test.tests_root,'test_helper.rb')

if File.exists? test_helper
  require test_helper
end
