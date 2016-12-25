Alki do
  require_dsl 'alki/dsls/class'
  require_dsl 'alki/dsls/assembly_group'

  finish do
    add :config_dir, build(:value, ctx[:config_dir])
    add :assembly_name, build(:value, ctx[:assembly_name])
    prefix_meta :original, ctx[:meta]

    root = ctx[:root]
    meta = ctx[:meta]
    add_class_method :root do
      root
    end
    add_class_method :meta do
      meta
    end
  end
end
