Alki do
  require_dsl 'alki/dsls/assembly_class'
  require_dsl 'alki/dsls/assembly_group'

  finish do
    add_value :config_dir, ctx[:config_dir]
    prefix_overlays :original, ctx[:overlays]
  end
end
