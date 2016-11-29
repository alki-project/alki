require_relative '../../test_helper'
require 'alki/dsls/assembly'
require 'alki/assembly_processor'

describe Alki::Dsls::Assembly do
  it 'should work' do
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
    p res[:class].assembly
    res[:class].assembly.children[:file].name.must_equal 'file'
    res[:class].assembly.children[:test].block.call.must_equal :val
    res[:class].assembly.children[:group1].children[:test2].block.call.must_equal :val2

    r = res[:class].assembly.lookup [:group1,:test2]
    p r
  end
end