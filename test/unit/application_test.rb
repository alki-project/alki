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

  describe :root do
    it 'should allow extracting the root group from the application' do
      @app.service(:test_m) { :test }
      @app.root.test_m.must_equal :test
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

  describe :group do
    it 'should create group with block' do
      @app.configure do
        group :g1 do
        end
      end
      @app.g1.wont_be_nil
    end

    it 'should add services to group' do
      @app.configure do
        group :g1 do
          service(:testm1) { :test1 }
        end
        group :g1 do
          service(:testm2) { :test2 }
        end
      end
      @app.g1.testm1.must_equal :test1
      @app.g1.testm2.must_equal :test2
    end

    it 'should allow creation of subgroups' do
      @app.configure do
        group :g1 do
          group :g2 do
            service(:test_m) { :test }
          end
        end
      end
      @app.g1.g2.test_m.must_equal :test
    end

    it 'should allow calling services of parent groups' do
      @app.configure do
        service(:test1) { :test1 }
        group :g1 do
          service(:test2) { :test2 }
          group :g2 do
            service(:test3) { [test1,test2] }
          end
        end
      end
      @app.g1.g2.test3.must_equal [:test1,:test2]
    end

    it 'should allow aliasing groups' do
      @app.configure do
        group :g1 do
          service(:test_m) { :test }
        end
      end
      @app.group(:g2,@app.g1)
      @app[:g2].test_m.must_equal :test
    end

    it 'should allow moving groups to other applications' do
      app2 = Alki::Application.new
      app2.service(:test_m) { :test }
      @app.group(:other,app2.root)
      @app.other.test_m.must_equal :test
    end

    it 'should raise ArgumentError if non-group is provided' do
      assert_raises ArgumentError do
        @app.group(:test, {})
      end
    end
  end

  describe :lookup do
    it 'should allow lookups of services by string' do
      @app.service(:test_m) { :test }
      @app.lookup('test_m').must_equal :test
    end

    it 'should allow looking up services in groups using dot separators' do
      @app.configure do
        group :g1 do
          service(:test_m) { :test1 }
          group :g2 do
            service(:test_m) { :test2 }
          end
        end
      end
      @app.lookup('g1.test_m').must_equal :test1
      @app.lookup('g1.g2.test_m').must_equal :test2
    end
  end
end
