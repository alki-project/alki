require 'alki/assembly/types/override'

Alki do
  attr :root
  attr :overrides, nil

  index do
    if key == :original
      data.merge!(main_data)
      root
    else
      if overrides
        data.replace(
          main: data.merge(main_data),
          override: override_data,
        )
        override.index data, key
      else
        root.index data.merge!(main_data), key
      end
    end
  end

  output do
    output = root.output(data)
    update_scope output[:scope]
    update_scope output[:full_scope]
    output[:scope].merge! overrides.output(data)[:scope] if overrides
    output[:full_scope].merge! overrides.output(data)[:full_scope] if overrides
    output
  end

  def override_data
    od = data.dup
    od[:scope] ||= {}
    add_original od[:scope]
    od
  end

  def main_data
    assembly_path = data[:prefix] ? data[:prefix].dup : []
    nd = {scope: {assembly: assembly_path, root: []}}
    update_scope nd[:scope]
    nd
  end

  def update_scope(scope)
    add_parent_path scope
    add_original scope
  end

  def add_parent_path(scope)
    parent_path = (data[:scope]||{})[:assembly]||nil
    scope[:parent] = parent_path if parent_path
  end

  def add_original(scope)
    scope[:original] = ((data[:prefix]||[]) + [:original])
  end

  def override
    Alki::Assembly::Types::Override.new root, overrides
  end
end
