require 'alki/test'
require 'alki/class_builder'

describe Alki::ClassBuilder do
  class DoitBuilder
    def initialize(c)
      @c = c
      @num = 0
    end

    def dsl_methods
      [:doit]
    end

    def doit(&blk)
      @c.send(:define_method,"doit#{@num}",&blk)
      @num += 1
    end

    def finalize
      num = @num
      @c.define_singleton_method :doits do
        num
      end

      @c.send(:define_method,:doit_all) do
        num.times.map {|i| send "doit#{i}"}
      end
    end
  end

  class JobTypeBuilder
    def initialize(c)
      @c = c
    end

    def dsl_methods
      [:job]
    end

    def job(job)
      @job = job
    end

    def finalize
      job = @job
      @c.send :define_method, :job do
        job
      end
    end
  end

  describe :build do
    it 'should allow calling methods in dsl' do
      c = Alki::ClassBuilder.build(DoitBuilder) do
        doit { "hello" }
        doit { "world" }
      end
      c.new.doit_all.must_equal ["hello","world"]
    end

    it 'should allow defining normal methods' do
      c = Alki::ClassBuilder.build(DoitBuilder) do
        def initialize(msg)
          @msg = msg
        end
        def msg
          @msg
        end
        doit { msg }
        doit { "world" }
      end
      obj = c.new "hello"
      obj.msg.must_equal "hello"
      obj.doit_all.must_equal ["hello","world"]
    end

    it 'should allow setting class methods' do
      c = Alki::ClassBuilder.build(DoitBuilder) do
        def klass.doit_count
          doits
        end
      end
      c.doit_count.must_equal 0
    end

    it 'should not make dsl methods available on class' do
      c = Alki::ClassBuilder.build(DoitBuilder) do
      end
      c.methods.wont_include :doit
      assert_raises NoMethodError do
        c.doit { puts "test" }
      end
      assert_raises NoMethodError do
        c.send(:doit) { puts "test" }
      end
    end

    it 'should only allow calling dsl methods returned from #dsl_methods' do
      assert_raises NoMethodError do
        Alki::ClassBuilder.build(DoitBuilder) do
          finalize()
        end
      end
    end

    it 'should allow creating classes with names' do
      Alki::ClassBuilder.build(:TestClass,DoitBuilder) do
      end
      TestClass.new.doit_all.must_equal []
    end

    it 'should allow creating classes in modules' do
      module TestModule; end
      Alki::ClassBuilder.build('TestModule::TestClass',DoitBuilder) do
      end
      TestModule::TestClass.new.doit_all.must_equal []
    end

    it 'should allow passing in multiple dsl builders' do
      c = Alki::ClassBuilder.build([DoitBuilder,JobTypeBuilder]) do
        job "greeter"
        doit { "Welcome!" }
      end
      obj = c.new
      obj.doit_all.must_equal ["Welcome!"]
      obj.job.must_equal "greeter"
    end
  end
end