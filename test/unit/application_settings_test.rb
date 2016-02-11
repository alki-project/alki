require_relative '../test_helper'

require 'alki/application_settings'

describe Alki::ApplicationSettings do
  before do
    @settings = Alki::ApplicationSettings.new
  end

  describe :initialize do
    it 'should set environment to development by default' do
      @settings.environment.must_equal :development
    end
  end

  describe :set do
    it 'should add setting as method and make it available as an index' do
      @settings.respond_to?(:test).must_equal false
      @settings.set :test, :test_value
      @settings.test.must_equal :test_value
    end

    it 'should make setting available as an index' do
      @settings[:test].must_equal nil
      @settings.set :test, :test_value
      @settings[:test].must_equal :test_value
    end
  end

  describe :environment? do
    it 'should return whether environment is one of the arguments' do
      @settings.environment?(:development).must_equal true
      @settings.environment?(:production,:development).must_equal true
      @settings.environment?(:production,:test).must_equal false
    end

    it 'should run provided block if true' do
      test = false
      @settings.environment?(:test) { test = true }
      test.must_equal false
      @settings.environment?(:development) { test = true }
      test.must_equal true
    end
  end

  describe :configure do
    it 'should run provided block in object context' do
      @settings.respond_to?(:test).must_equal false
      @settings.configure do
        set :test, :test_value
        test.must_equal :test_value
      end
      @settings.test.must_equal :test_value
    end
  end
end