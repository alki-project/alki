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
end
