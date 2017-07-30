Alki do
  attr :main
  attr :override

  index do
    main_child = main.index data[:main], key
    override_child = override.index data[:override], key

    if main_child && override_child
      (data[:main][:scope]||={}).merge! (data[:override][:scope]||{})
      Alki::Assembly::Types::Override.new main_child, override_child
    elsif main_child
      data.replace data[:main]
      main_child
    elsif override_child
      data.replace data[:override]
      override_child
    end
  end

  output do
    result = override.output(data[:override])
    if result[:type] == :group
      main_result = main.output(data[:main])
      if main_result[:type] == :group
        result[:scope] = main_result[:scope].merge result[:scope]
      end
    end
    result
  end
end
