require 'alki/feature_test'

describe 'Overlays' do
  it 'should allow setting an overlay on a service' do
    values = []
    assembly = Alki.create_assembly do
      service :svc do
        :test
      end

      overlay :svc, :test_overlay

      set :test_overlay, ->(value) {values << value; :transformed}
    end
    assembly.new.svc.must_equal :transformed
    values.must_equal [:test]
  end

  it 'should call new if overlay responds to it' do
    assembly = Alki.create_assembly do
      service :svc do
        :test
      end

      overlay :svc, :test_overlay

      set :test_overlay, Struct.new(:val)
    end
    assembly.new.svc.val.must_equal :test
  end

  it 'should allow using factories as overlays' do
    values = []
    assembly = Alki.create_assembly do
      service :svc do
        :test
      end

      overlay :svc, :test_overlay

      factory :test_overlay do
        ->(value) {values << value; :transformed}
      end
    end
    assembly.new.svc.must_equal :transformed
    values.must_equal [:test]
  end

  it 'should allow setting an overlay on groups of services' do
    values = []
    assembly = Alki.create_assembly do
      service :svc do
        :test
      end

      group :svcs do
        service :one do
          :svc_one
        end

        service :two do
          :svc_two
        end
      end

      overlay :svcs, :test_overlay

      set :test_overlay, ->(value) {values << value; "overlay_#{value}".to_sym}
    end
    obj = assembly.new
    obj.svc.must_equal :test
    obj.svcs.one.must_equal :overlay_svc_one
    obj.svcs.two.must_equal :overlay_svc_two
    values.must_equal [:svc_one,:svc_two]
  end

  it 'should not apply to non-services' do
    values = []
    assembly = Alki.create_assembly do
      group :vals do
        set :one do
          :val_one
        end

        factory :two do
          ->(v) { "val_two_#{v}".to_sym }
        end

        func :three do
          :val_three
        end
      end

      overlay :vals, :test_overlay

      set :test_overlay, ->(value) {values << value; "overlay_#{value}".to_sym}
    end
    obj = assembly.new
    obj.vals.one.must_equal :val_one
    obj.vals.two(1).must_equal :val_two_1
    obj.vals.three.must_equal :val_three
    values.must_equal []
  end

  it 'should chain overlays when multiple are set' do
    values = []
    assembly = Alki.create_assembly do

      group :svcs do
        service :svc do
          :test
        end
      end

      overlay :svcs, :overlay1
      overlay 'svcs.svc', :overlay2

      set :overlay1, ->(value) {values << value; "overlay_#{value}".to_sym}
      set :overlay2, ->(value) {values << value; :transformed}

    end
    obj = assembly.new
    obj.svcs.svc.must_equal :transformed
    values.must_equal [:test,:overlay_test]
  end

  it 'should follow paths when setting overlay targets' do
    values = []
    assembly = Alki.create_assembly do
      service :svc do
        :test
      end

      group :grp do
        overlay 'assembly.svc', :test_overlay

        set :test_overlay, ->(value) {values << value; :transformed}
      end
    end
    obj = assembly.new
    obj.svc.must_equal :transformed
    values.must_equal [:test]
  end

  it 'should raise error if either target or overlay paths are invalid' do
    assembly = Alki.create_assembly do
      service :svc do
        :test
      end
      overlay :invalid, :test_overlay
      set :test_overlay, ->(value) {:child}
    end
    assert_raises Alki::InvalidPathError do
      assembly.new.svc
    end
    assembly = Alki.create_assembly do
      service :svc do
        :test
      end
      overlay :svc, :invalid
    end
    assert_raises Alki::InvalidPathError do
      assembly.new.svc
    end
  end

  it 'should set overlays through mounted assemblies' do
    child = Alki.create_assembly do
      service :svc do
        :test
      end
      overlay 'parent.svc', :test_overlay
      set :test_overlay, ->(value) {:child}
    end
    assembly = Alki.create_assembly do
      service :svc do
        :test
      end
      mount :mounted, child
      overlay 'mounted.svc', :test_overlay
      set :test_overlay, ->(value) {:parent}
    end
    obj = assembly.new
    obj.svc.must_equal :child
    obj.mounted.svc.must_equal :parent
  end

  it 'should set overlays from overrides' do
    child = Alki.create_assembly do
      service :svc1 do
        :test
      end
    end
    assembly = Alki.create_assembly do
      service :svc2 do
        :test
      end
      mount :mounted, child do
        overlay 'original.svc1', :test_overlay
        set :test_overlay, ->(value) {:parent}
      end
    end
    obj = assembly.new do
      overlay 'original.svc2', :test_overlay
      set :test_overlay, ->(value) {:child}
    end
    obj.svc2.must_equal :child
    obj.mounted.svc1.must_equal :parent
  end

  it 'should allow setting overlays on assembly_instance' do
    values = []
    mock = Minitest::Mock.new
    assembly = Alki.create_assembly do
      overlay :assembly_instance, :test_overlay
      set :val, 1
      set :test_overlay, ->(value) {
        values << value
        mock
      }
    end
    mock.expect :val, 2
    assembly.new.val.must_equal 2
    values.size.must_equal 1
    values[0].val.must_equal 1
  end
end
