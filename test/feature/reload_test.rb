require 'alki/feature_test'

describe 'Reload' do
  before do
    counter = 0
    @assembly = Alki.create_assembly do
      service :svc do
        counter += 1
      end
    end
    @obj = @assembly.new
  end

  it 'should cause services to be rebuilt' do
    @obj.svc.must_equal 1
    @obj.__reload__
    @obj.svc.must_equal 2
  end

  it 'should increment version number of assembly' do
    @obj.__version__.must_equal 0
    @obj.svc
    @obj.__reload__
    @obj.__version__.must_equal 1
  end

  it 'should not reload if the assembly hasn\'t been used' do
    @obj.__version__.must_equal 0
    @obj.__reload__
    @obj.__version__.must_equal 0
  end

  it 'should work if reloading after previous loading raises an error' do
    assembly = @assembly
    raise_error = []
    proxy = Class.new do
      define_method :root do
        raise SyntaxError, 'error' unless raise_error.empty?
        assembly.root
      end
      define_method :meta do
        assembly.meta
      end
    end.new
    obj = Alki::Assembly::Instance.new proxy, Alki::OverrideBuilder.build
    obj.svc.must_equal 1
    ref = obj.__reference_svc__
    raise_error.push true
    obj.__reload__
    assert_raises(SyntaxError) do
      obj.svc
    end
    raise_error.pop
    obj.svc.must_equal 2
  end
end
