Alki do
  require_dsl 'alki/dsls/class'
  require_dsl 'alki/dsls/assembly_types/group'
  require_dsl 'alki/dsls/assembly_types/value'
  require_dsl 'alki/dsls/assembly_types/assembly'
  require_dsl 'alki/dsls/assembly_types/load'
  require_dsl 'alki/dsls/assembly_types/overlay'

  init do
    ctx[:elems] = {}
    ctx[:overlays] = []
  end

  finish do
    root = build_group(ctx[:elems], ctx[:overlays])
    add_class_method :root do
      root
    end
  end
end