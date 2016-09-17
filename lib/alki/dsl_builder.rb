module Alki
  class DslBuilder
    def initialize(*dsl_factories,builder: nil, exec: nil)
      @builder = builder
      @exec = exec
      @dsl_factories = dsl_factories.flatten
    end

    def build(obj,&blk)
      self.class.build(obj,@dsl_factories,
                       builder: @builder,
                       exec: @exec,
                       &blk)
    end

    def self.build(obj,dsl_factories,builder: nil, exec: nil, &blk)
      builder ||= Object.method(:new)
      exec ||= :instance_exec
      unless dsl_factories.is_a?(Array)
        dsl_factories = [dsl_factories]
      end
      builder = builder.call
      dsls = []
      dsl_factories.each do |dsl_factory|
        if dsl_factory.respond_to? :new_dsl
          dsl = dsl_factory.new_dsl obj
        else
          dsl = dsl_factory.new obj
        end
        dsl.dsl_methods.each do |method_name|
          method = dsl.method(method_name)
          builder.define_singleton_method method_name do |*args,&blk|
            method.call *args, &blk
          end
        end
        dsls << dsl
      end
      builder.send(exec,&blk)
      dsls.each {|dsl| dsl.finalize if dsl.respond_to? :finalize }
      builder
    end
  end
end