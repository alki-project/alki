require_relative '../test_helper'

$LOAD_PATH.unshift Alki::Test.fixture_path('tlogger','lib')
require 'tlogger'
require 'stringio'

describe 'Overrides' do
  it 'should be possibly to override assembly values on initialize' do
    assert_raises RuntimeError do
      Tlogger.new.log << "test"
    end
    io = StringIO.new
    logger = Tlogger.new(io: io)
    logger.log << "test"
    logger.log << "test"
    io.string.must_equal "testtest"
  end
end
