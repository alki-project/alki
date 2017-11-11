Alki do
  require_dsl 'alki/dsls/class'

  init do
    @uses = []
  end

  helper :add_use do |name,service_path = name|
    if name.is_a?(Hash) && name.size == 1
      name, service_path = name.to_a.first
    end
    add_initialize_param name
    @uses << service_path.to_s
  end

  dsl_method :use do |name,service_path = name|
    add_use name, service_path
  end

  finish do
    uses = @uses
    add_class_method :uses do
      uses
    end
  end
end
