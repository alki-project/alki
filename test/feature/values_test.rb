require 'alki/feature_test'

describe 'Values' do
  it 'should not be altered' do
    obj = Class.new(MiniTest::Mock) do
      def respond_to?(*_)
        true
      end
    end.new
    Alki.singleton_assembly do
      set :obj, obj
    end
  end
end
