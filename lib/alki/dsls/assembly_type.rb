require 'alki/assembly_handler_base'

Alki do
  require_dsl 'alki/dsls/class'

  init do
    set_super_class Alki::AssemblyHandlerBase, subclass: 'Handler'

    add_method :handler, private: true do |*args|
      self.class::Handler.new(self,*args)
    end

    add_method :index do |*args|
      handler(*args).index
    end

    add_method :output do |*args|
      handler(*args).output
    end

    add_method :lookup do |path,data={}|
      data = data.dup
      elem = self
      path.each do |key|
        elem = elem.index data, key
        return nil unless elem
      end
      elem.output data
    end

    # Add defined methods to handler class
    class_builder('Handler')[:module] = class_builder[:module]
  end

  dsl_method :attr do |name,default=nil|
    add_delegator name, :@elem, subclass: 'Handler'
    add_initialize_param name, default
    add_accessor name
  end

  dsl_method :index do |&blk|
    add_method :index, subclass: 'Handler', &blk
  end

  dsl_method :output do |&blk|
    add_method :output, subclass: 'Handler', &blk
  end
end