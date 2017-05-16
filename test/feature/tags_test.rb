require 'alki/feature_test'

describe 'Tags' do
  it 'should allow accessing tags in services' do
    assembly = Alki.create_assembly do
      tag :tag1, tag2: false
      group :grp do
        tag :tag2, tag3: :value
        service :svc1 do
          meta[:tags]
        end
      end
    end
    obj = assembly.new
    obj.grp.svc1.must_equal tag1: true, tag2: true, tag3: :value
  end

  it 'should allow setting overlays via tags' do
    assembly = Alki.create_assembly do
      tag :tag1, :tag2
      service :svc1 do
        :svc1
      end

      tag :tag1
      service :svc2 do
        :svc2
      end

      overlay '%tag1', :overlay1
      overlay '%tag2', :overlay2

      set :overlay1, -> val { :"one_#{val}"}
      set :overlay2, -> val { :"two_#{val}"}
    end
    obj = assembly.new

    obj.svc1.must_equal :two_one_svc1
    obj.svc2.must_equal :one_svc2
  end

  it 'should apply to all elements in groups' do
    assembly = Alki.create_assembly do
      tag :tag1
      group :grp do
        service :svc1 do
          :svc1
        end

        service :svc2 do
          :svc2
        end
      end

      overlay '%tag1', :overlay1
      set :overlay1, -> val { :"one_#{val}"}
    end
    obj = assembly.new

    obj.grp.svc1.must_equal :one_svc1
    obj.grp.svc2.must_equal :one_svc2
  end

  it 'should be accessible through mounts' do
    child = Alki.create_assembly do
      tag :tag1
      service :svc1 do
        :svc1
      end

      overlay '%tag2', :overlay
      set :overlay, -> val { :"child_#{val}"}
    end

    assembly = Alki.create_assembly do
      mount :child, child

      tag :tag2
      service :svc2 do
        :svc2
      end

      overlay '%tag1', :overlay
      set :overlay, -> val { :"parent_#{val}"}
    end
    obj = assembly.new

    obj.svc2.must_equal :child_svc2
    obj.child.svc1.must_equal :parent_svc1
  end
end
