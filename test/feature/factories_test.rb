require 'alki/feature_test'

describe 'Factories' do
  def assembly(&blk)
    @assembly = Alki.create_assembly(&blk)
  end

  def obj
    @obj ||= @assembly.new
  end

  it 'should call returned callable when referenced' do
    assembly do
      factory :test do
        -> (val) { val + 1 }
      end
    end
    obj.test(1).must_equal 2
  end

  it 'should evaluate the given block once' do
    counter = 0
    proc_counter = 0
    assembly do
      factory :test do
        counter += 1
        -> (val) {
          proc_counter += 1
          val
        }
      end
    end
    obj.test(1)
    obj.test(1)
    counter.must_equal 1
    proc_counter.must_equal 2
  end

  describe 'if no arguments are provided' do
    before do
      assembly do
        factory :test do
          -> (val) { val + 1 }
        end
      end
    end

    def just_yield(*args)
      yield *args
    end

    it 'should return object with call methods' do
      obj.test.call(1).must_equal 2
      obj.test[1].must_equal 2
      obj.test.(1).must_equal 2
    end

    it 'should return object with #new method' do
      obj.test.new(1).must_equal 2
    end

    it 'should return object that is convertible to a proc' do
      just_yield(1,&obj.test).must_equal 2
    end
  end
end
