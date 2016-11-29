require_relative '../../test_helper'
require 'alki/dsls/service'

describe Alki::Dsls::Service do
  def build(&blk)
    @c = Alki::Dsls::Service.build(&blk)[:class]
  end

  describe :use do
    it 'should add second argument to ::uses' do
      build do
        use :test, 'test_service'
        use :test2, :test_service2
      end.uses.must_equal(['test_service','test_service2'])
    end

    it 'should set instance variable for each use from new arguments' do
      build do
        use :test, 'test_service'
        use :test2, 'test_service2'
      end
      obj = @c.new :val1, :val2
      obj.instance_variable_get(:@test).must_equal :val1
      obj.instance_variable_get(:@test2).must_equal :val2
    end

    it 'should raise error if number of new arguments doesn\'t match number of use statements' do
      build do
        use :test, 'test_service'
        use :test2, 'test_service2'
      end
      assert_raises ArgumentError do
        @c.new
      end
      assert_raises ArgumentError do
        @c.new :val1
      end
      assert_raises ArgumentError do
        @c.new :val1, :val2, :val3
      end
    end

    it 'should use first argument as service name if none provided' do
      build do
        use :test
        use :test2
      end.uses.must_equal(['test','test2'])
    end

    it 'should allow hash syntax for arguments' do
      build do
        use test: 'ts'
        use test2: 'ts2'
      end.uses.must_equal(['ts','ts2'])
    end
  end
end