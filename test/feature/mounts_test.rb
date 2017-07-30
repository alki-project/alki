require 'alki/feature_test'

describe 'Mounts' do
  it 'should attach assembly to main assembly as a group' do
    Alki.create_assembly(name: 'alki_test') do
      set :val, :test
    end

    assembly = Alki.singleton_assembly do
      mount :mounted, AlkiTest
    end

    assembly.mounted.val.must_equal :test
  end
end
