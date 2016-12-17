require 'alki/dsls/assembly_type'

Alki do
  require_dsl 'alki/dsls/dsl'
  init do
    add_helper :add do |name,elem|
      (ctx[:elems]||={})[name.to_sym] = elem
      nil
    end
  end

  dsl_method :element_type do |name,&blk|
    data = Alki::Dsls::AssemblyType.build(prefix: 'alki/assembly_types', name: name,&blk)
    klass = data[:class]
    add_helper "build_#{name}".to_sym, &klass.method(:new)
    add_helper "add_#{name}".to_sym do |name,*args|
      add name, klass.new(*args)
    end
  end
end
