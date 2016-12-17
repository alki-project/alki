Alki do
  require_dsl 'alki/dsls/class'

  finish do
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
