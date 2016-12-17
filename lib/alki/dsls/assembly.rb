Alki do
  require_dsl 'alki/dsls/class'
  require_dsl 'alki/dsls/assembly_group'

  finish do
    add :config_dir, build(:value, ctx[:config_dir])
    prefix_overlays :original, ctx[:overlays]

    root = ctx[:root]
    overlays = ctx[:overlays]
    add_class_method :root do
      root
    end
    add_class_method :overlays do
      overlays
    end
  end
end
