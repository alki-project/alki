Alki do
  require 'ice_nine'
  require_dsl 'alki/dsls/class'
  require_dsl 'alki/dsls/assembly_group'

  finish do
    add :config_dir, build(:value, ctx[:config_dir])
    add :assembly_name, build(:value, ctx[:assembly_name])

    root = IceNine.deep_freeze ctx[:root]
    meta = IceNine.deep_freeze ctx[:meta]
    add_class_method :root do
      root
    end
    add_class_method :meta do
      meta
    end
  end
end
