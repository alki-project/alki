require 'alki/feature_test'
require 'logger'
require 'stringio'

describe 'Overrides' do
  before do
    @assembly = Alki.create_assembly do
      set :val do
        :value
      end

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
          logger_class.new log_io
        end
      end
    end
    instance.util.logger.info "test"
    io.string.must_equal "INFO test"
  end

  it 'should allow calling original when mounted' do
    other = @assembly
    instance = Alki.new do
      mount :assembly, other do
        set :val do
          original.val
        end
      end
    end
    instance.assembly.val.must_equal :value
  end

  it 'should allow calling original service' do
    instance = @assembly.new do
      set :val do
        original.val
      end
    end
    instance.val.must_equal :value
  end
end
