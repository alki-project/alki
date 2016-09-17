require_relative '../test_helper'

require 'alki/loader'

describe Alki::Loader do
  describe 'load' do
    before do
      @loader = Alki::Loader.new fixtures_path
    end

    it 'should load config file from root directory' do
      @loader.load(:config).call.must_equal 0
    end
  end

  describe 'self.load' do
    before do
      @config_path = fixture_path('config.rb')
    end

    it 'should load a config file and call block with proc' do
      Alki::Loader::load(@config_path).call.must_equal 0
    end

    it 'should be threadsafe' do
      t1 = Thread.new do
        $wait = 1
        Alki::Loader::load(@config_path).call
      end
      sleep 0.1
      $wait = 0
      Alki::Loader::load(@config_path).call.must_equal 0
      t1.value.must_equal 1
    end
  end
end