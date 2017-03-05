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
end
