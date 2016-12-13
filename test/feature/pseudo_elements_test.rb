require 'alki/feature_test'

describe 'Pseudo Elements' do
  before do
    @config_dir = fixture_path('example','config')
    two = Alki.create_assembly do
      set :num, 2
      set :assembly_num do
        assembly.num
      end
      set :parent_num do
        parent.num
      end
      set :grandparent_num do
        parent.parent.num
      end
      set :root_num do
        root.num
      end
    end
    one = Alki.create_assembly do
      assembly :two, two
      set :num, 1
    end
    zero = Alki.create_assembly(config_dir: @config_dir) do
      assembly :one, one
      set :num, 0
      set :has_parent do
        respond_to?(:parent)
      end
    end
    @assembly = zero
    @obj = @assembly.new
  end

  describe 'assembly' do
    it 'should be the local assembly of the referring element' do
      @obj.one.two.assembly_num.must_equal 2
    end
  end

  describe 'parent' do
    it 'should be the parent assembly of the referring element' do
      @obj.one.two.parent_num.must_equal 1
    end

    it 'should be attribute on all assemblies with parents' do
      @obj.one.two.grandparent_num.must_equal 0
    end

    it 'should only exist if assembly has parent' do
      @obj.has_parent.must_equal false
    end
  end

  describe 'root' do
    it 'should be the root assembly' do
      @obj.one.two.root_num.must_equal 0
    end
  end

  describe 'config_dir' do
    it 'should be the config_dir setting set in the assembly when it was created' do
      @obj.config_dir.must_equal @config_dir
    end
  end
end
