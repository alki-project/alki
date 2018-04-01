require 'alki/feature_test'

describe 'Auto Group' do
  before do
    @assembly = Alki.create_assembly do
      auto_group :grp, fixture_path('auto_group','lib','auto_group_test'), :construct

      factory :construct do
        -> name { Alki.load(name).new }
      end
    end
    @obj = @assembly.new
  end

  it 'should create a group containing all items' do
    @obj.grp.children.sort.must_equal [:a,:one]
    @obj.grp.one.value.must_equal 1
    @obj.grp.a.children.must_equal [:two]
    @obj.grp.a.two.value.must_equal 2
  end
end
