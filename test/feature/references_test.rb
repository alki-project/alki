require 'alki/feature_test'

describe 'References' do
  describe 'circular references' do
    before do
      @assembly = Alki.singleton_assembly do
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
end
