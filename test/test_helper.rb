require 'rubygems'
require 'bundler'
Bundler.require(:default,:test)
require 'minitest/autorun'

module TestHelper
  def self.root
    File.expand_path '../..', __FILE__
  end

  def self.lib
    File.join root, 'lib'
  end

  def self.test_root
    File.join root, 'test'
  end

  def self.test_path(*args)
    File.join test_root, *args
  end

  def self.test_resources
    File.join test_root, 'resources'
  end

  def self.fixtures_path
    File.join(test_root, 'fixtures')
  end

  def self.fixture_path(fixture)
    File.join(fixtures_path, "#{fixture}.rb")
  end

  def self.load_fixture(fixture)
    require fixture_path(fixture)
  end
end

$LOAD_PATH << TestHelper.lib
