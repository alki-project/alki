require 'alki/test'
require 'alki/dsls/assembly_type'

describe Alki::Dsls::AssemblyType do
  def build(&blk)
    @klass = Alki::Dsls::AssemblyType.build(&blk)
  end

  def klass
    @klass
  end

  describe :build do
    it 'should create struct class with given attributes' do
      build do
        attr :attr1
        attr :attr2
      end
      obj = klass.new(:val1,:val2)
      obj.attr1.must_equal :val1
      obj.attr2.must_equal :val2
    end

    it 'should create index and output methods using given blocks' do
      build do
        index do
          :val1
        end

        output do
          :val2
        end
      end

      obj = klass.new
      obj.index(:data,:key).must_equal :val1
      obj.output(:data).must_equal :val2
    end

    it 'should allow accessing attrs and processor/data/key from index/output methods' do
      build do
        attr :attr1

        index do
          [attr1,data,key].map(&:to_s).join
        end

        output do
          [attr1,data].map(&:to_s).join
        end
      end

      obj = klass.new(1)
      obj.index(2,3).must_equal "123"
      obj.output(2).must_equal "12"
    end
  end
end
