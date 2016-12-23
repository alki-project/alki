require 'alki/feature_test'

describe Alki do
  describe :create_assembly do
    def build(opts={},&blk)
      Alki.create_assembly opts, &blk
    end

    it 'should return module with ::assembly, ::root, and ::new methods' do
      klass = build
      klass.must_respond_to :root
      klass.must_respond_to :new
    end

    it 'should use provided block to provide assembly definition' do
      klass = build do
        service :svc do
          :val1
        end
      end
      klass.new.svc.must_equal :val1
    end

    it 'should load assembly definition from config_dir if provided' do
      build(name: 'tlogger', config_dir: fixture_path('tlogger','config')).new.must_respond_to :log
    end

    it 'should load file other than assembly if provided with primary_config' do
      build(
        name: 'example',
        config_dir: fixture_path('example','config'),
        primary_config: 'settings'
      ).new.must_respond_to :fizz
    end

    it 'should create class if provided with a name' do
      klass = build(name: 'alki_test/test_assembly')
      AlkiTest::TestAssembly.must_equal klass
      undefine :AlkiTest
    end

    it 'should automatically determine config_dir and name if project_assembly provided' do
      klass = build(project_assembly: fixture_path('tlogger','lib','tlogger.rb'))
      Tlogger.must_equal klass
      klass.new.must_respond_to :log
    end
  end

  describe :project_assembly! do
    it 'should automatically set path option using path of caller' do
      require fixture_path('tlogger','lib','tlogger.rb')
      Tlogger.new.must_respond_to :log
    end
  end
end
