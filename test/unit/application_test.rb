require_relative '../test_helper'

require 'alki/application'

describe Alki::Application do
  before do
    @settings = {test: 1}
    @app = Alki::Application.new @settings
  end

  describe :settings do
    it 'should return settings passed into new' do
      @app.settings.must_be_same_as @settings
    end
  end

  describe :configure do
    it 'should allow calling methods as a DSL' do
      @app.configure do
        service :test_m do
          :test
        end
      end
      @app.test_m.must_equal :test
    end
  end

  describe :root_group do
    it 'should allow extracting the root group from the application' do
      @app.service(:test_m) { :test }
      @app.root_group.test_m.must_equal :test
    end
  end

  describe :service do
    it 'should create method that gets result of block' do
      @app.service(:test_m) { :test }
      @app.respond_to?(:test_m).must_equal true
      @app.test_m.must_equal :test
    end

    it 'generated method should run on demand' do
      count = 0
      @app.service(:test_m){ count += 1; :test }
      count.must_equal 0
      @app.test_m
      count.must_equal 1
    end

    it 'generated method should run only once' do
      count = 0
      @app.service(:test_m){ count += 1; :test }
      @app.test_m
      @app.test_m
      count.must_equal 1
    end
  end

  describe :[] do
    it 'should get or automatically create group' do
      g1 = @app[:g1]
      g1.wont_be_nil
      @app[:g1].must_equal g1
    end

    it 'should return group that has services' do
      @app[:g1].service(:test_m) { :test }
      @app[:g1].test_m.must_equal :test
    end

    it 'should return group that has subgroups' do
      @app[:g1][:g2].wont_be_nil
    end
  end

  describe :lookup do
    it 'should allow lookups of services by string' do
      @app.service(:test_m) { :test }
      @app.lookup('test_m').must_equal :test
    end

    it 'should allow looking up services in groups using colon separators' do
      @app[:g1].service(:test_m) { :test }
      @app.lookup('g1:test_m').must_equal :test
      @app[:g1][:g2].service(:test_m) { :test }
      @app.lookup('g1:g2:test_m').must_equal :test
    end
  end

  describe :[]= do
    it 'should allow aliasing groups' do
      @app[:g1].service(:test_m) { :test }
      @app[:g2] = @app[:g1]
      @app[:g2].test_m.must_equal :test
    end

    it 'should allow moving groups to other applications' do
      app2 = Alki::Application.new
      app2.service(:test_m) { :test }
      @app[:other] = app2.root_group
      @app[:other].test_m.must_equal :test
    end

    it 'should raise ArgumentError if non-group is provided' do
      assert_raises ArgumentError do
        @app[:test] = {}
      end
    end
  end
end
