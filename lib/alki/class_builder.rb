require 'alki/dsl_builder'

module Alki
  class ClassBuilder
    def initialize(*dsl_factories)
      @dsl_factories = dsl_factories.flatten
    end

    def build(name=nil,&blk)
      self.class.build(name,@dsl_factories,&blk)
    end

    def self.build(name=nil,dsl_factories,&blk)
      Class.new.tap do |c|
        builder = -> {
          Module.new.tap do |m|
            m.define_singleton_method :klass do
              c
            end
          end
        }
        m = DslBuilder.build(c,dsl_factories,
                         builder: builder,exec: :class_exec,
                         &blk)
        c.include m
        if name
          *ans, ln = name.to_s.split(/::/)
          parent = Object
          ans.each do |a|
            unless parent.const_defined? a
              parent.const_set a, Module.new
            end
            parent = parent.const_get a
          end

          parent.const_set ln, c
        end
      end
    end
  end
end