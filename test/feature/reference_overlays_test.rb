require 'alki/feature_test'

describe 'Reference Overlays' do
  it 'should allow overlaying all references made by a service' do
    assembly = Alki.create_assembly do
      set :val, :val
      service :svc_ref do
        :svc
      end
      func :func do
        :func
      end
      factory :fact do
        -> val { val }
      end
      service :svc do
        :"#{val}_#{svc_ref}_#{func}_#{fact(:f1)}_#{fact(:f2)}"
      end
      reference_overlay :svc, :overlay
      set :overlay, -> ref { :"o#{ref.call}"}
    end
    assembly.new.svc.must_equal :oval_osvc_ofunc_of1_of2
  end

  it 'should work on tags across mounts' do
    child = Alki.create_assembly do
      set :val, :svc1

      tag :tag1
      service :svc1 do
        val
      end

      reference_overlay '%tag2', :overlay
      set :overlay, -> val { :"child_#{val.call}"}
    end

    assembly = Alki.create_assembly do
      mount :child, child

      set :val2, :svc2

      tag :tag2
      service :svc2 do
        val2
      end

      reference_overlay '%tag1', :overlay
      set :overlay, -> val { :"parent_#{val.call}"}
    end
    obj = assembly.new

    obj.svc2.must_equal :child_svc2
    obj.child.svc1.must_equal :parent_svc1
  end
end
