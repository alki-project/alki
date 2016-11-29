require 'bundler'
Bundler.setup(:default,:test)
require 'minitest/autorun'
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

class Minitest::Spec
  include Alki::Test
end

unless $LOAD_PATH.include? Alki::Test.lib_dir
  $LOAD_PATH.unshift Alki::Test.lib_dir
end

test_helper_dir = File.join(Alki::Test.tests_root,'test_helper.rb')

if File.exists? test_helper_dir
  require test_helper_dir
end
