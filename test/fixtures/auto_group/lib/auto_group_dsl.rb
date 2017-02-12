Alki do
  require_dsl 'alki/dsls/class'

  dsl_method :value do |val|
    add_method :value do
      val
    end
  end
end
