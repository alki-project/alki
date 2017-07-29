Alki do
  attr :group

  index do
    group.index data, key
  end

  output do
    data[:prefix] << :original
    group.output(data)
  end
end
