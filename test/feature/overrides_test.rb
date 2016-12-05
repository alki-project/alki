require_relative '../test_helper'
require 'logger'
require 'alki'
require 'stringio'

describe 'Overrides' do
  before do
    @assembly = Alki.create_assembly do
      set :log_io do
        raise "Must set log_io"
      end
      group :util do
        service :logger do
          require 'logger'
          Logger.new log_io
        end
      end
    end
  end

  it 'should be possibly to override assembly values on initialize' do
    assert_raises RuntimeError do
      @assembly.new.util.logger << "test"
    end
    io = StringIO.new
    logger = @assembly.new(log_io: io)
    logger.util.logger << "test"
    logger.util.logger << "test"
    io.string.must_equal "testtest"
  end

  it 'should allow overriding via block' do
    logger_class = Class.new(Logger) do
      def info(msg)
        self << "INFO #{msg}"
      end
    end
    io = StringIO.new
    instance = @assembly.new do
      set :log_io, io
      group :util do
        service :logger do
          logger_class.new original.log_io
        end
      end
    end
    instance.util.logger.info "test"
    io.string.must_equal "INFO test"
  end
end
