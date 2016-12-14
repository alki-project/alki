require 'alki/test'
require 'alki/dsls/assembly'

describe Alki::Dsls::Assembly do
  it 'should allow creating Assembly config classes' do
    res = Alki::Dsls::Assembly.build do
      service :test do
        :val
      end

      load 'file'

      group :group1 do
        service :test2 do
          :val2
        end
      end
    end
    res[:class].root.children[:file].name.must_equal 'file'
    res[:class].root.children[:test].must_respond_to :block
    res[:class].root.children[:group1].children[:test2].must_respond_to :block

    r = res[:class].root.lookup [:group1,:test2]
  end
end
