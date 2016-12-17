Alki do
  require_dsl 'alki/dsls/assembly_types/group'
  require_dsl 'alki/dsls/assembly_types/value'
  require_dsl 'alki/dsls/assembly_types/mount'
  require_dsl 'alki/dsls/assembly_types/overlay'

  init do
    ctx[:elems] = {}
    ctx[:overlays] = []
  end

  finish do
    ctx[:root] = build_group(ctx.delete(:elems))
  end
end
