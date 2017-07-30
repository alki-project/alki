require 'alki/feature_test'

describe 'Try mounts' do
  it 'should not mount if other assembly can be found' do
    obj = Alki.singleton_assembly do
      try_mount :other, 'missing_assembly'
      set :val do
        respond_to? :other
      end
    end
    obj.val.must_equal false
  end

  it 'should mount if other assembly can be found' do
    obj = Alki.singleton_assembly do
      try_mount :other, 'example' # example fixture assembly
      set :val do
        respond_to? :other
      end
    end
    obj.val.must_equal true
  end
end
