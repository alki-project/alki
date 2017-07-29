require 'alki/assembly/types/override'
require 'alki/assembly/types/original'

Alki do
  attr :root
  attr(:overrides) { nil }

  index do
    data[:scope] ||= {}
    data[:prefix] ||= []
    data[:overlays] ||= {}

    if key == :original
      update_main data
      if overrides
        overrides.children.keys.each do |k|
          data[:scope][k] = data[:prefix] + [k]
        end
      end
      Alki::Assembly::Types::Original.new root
    else
      if overrides
        data.replace(
          main: deep_copy(data),
          override: data.dup,
        )
        update_main data[:main]
        update_override data[:override]
        override.index data, key
      else
        update_main data
        root.index data, key
      end
    end
  end

  output do
    data[:scope] ||= {}
    data[:prefix] ||= []
    data[:overlays] ||= {}

    output = root.output(data)
    add_parent_path output[:scope]
    update_scope data, output[:full_scope]
    output[:scope].merge! overrides.output(data)[:scope] if overrides
    output[:full_scope].merge! overrides.output(data)[:full_scope] if overrides
    output
  end

  def deep_copy(val)
    if val.is_a?(Hash)
      val.inject({}) do |h,(k,v)|
        h[k] = deep_copy v
        h
      end
    elsif val.is_a?(Array)
      val.inject([]) do |a,v|
        a.push deep_copy v
      end
    else
      val
    end
  end

  def update_main(data)
    data[:scope] = {assembly: data[:scope][:assembly], root: []}
    update_scope data
    data[:scope][:assembly] = data[:prefix].dup
  end

  def update_override(data)
    data[:scope][:root] ||= []
    add_original data[:scope], data
  end

  def update_scope(data,scope=data[:scope])
    scope[:root] = []
    add_parent_path scope, data
    add_original scope, data
  end

  def add_parent_path(scope,data=self.data)
    parent_path = data[:scope][:assembly]||nil
    scope[:parent] = parent_path if parent_path
  end

  def add_original(scope,data=self.data)
    scope[:original] = data[:prefix] + [:original]
  end

  def override
    Alki::Assembly::Types::Override.new root, overrides
  end
end
