require 'alki/feature_test'

describe 'References' do
  describe 'circular references' do
    before do
      @assembly = Alki.new do
        set :a do
          b
        end

        set :b do
          c
        end

        set :c do
          a
        end

        set :d do
          a
        end
      end
    end

    it 'should raise CircularReferenceError' do
      err = assert_raises Alki::CircularReferenceError do
        @assembly.d
      end

      err.to_s.split("\n")[1..-1].must_equal(
        [ '  d', '> a', '  b', '  c', '> a' ]
      )
    end
  end

  describe 'reference objects' do
    before do
      @obj = Alki.new do
        service :broken do
          1.foo
        end
      end
    end
    it 'should raise errors correctly after reload' do
      ref = @obj.__reference_broken__
      assert_raises NoMethodError do
        ref.call
      end
      @obj.__reload__
      assert_raises NoMethodError do
        ref.call
      end
    end
  end
end
