require_relative '../test_helper'

require 'alki/loader'

describe Alki::Loader do
  before do
    @config_path = TestHelper.fixture_path('config')
  end

  describe 'load' do
    before do
      @loader = Alki::Loader.new TestHelper.fixtures_path
    end

    it 'should load config file from root directory' do
      @loader.load(:config).call.must_equal :test
    end
  end

  describe 'self.load' do
    it 'should load a config file and call block with proc' do
      Alki::Loader::load(@config_path).call.must_equal :test
    end
  end
end