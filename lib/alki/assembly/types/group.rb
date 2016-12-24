Alki do
  require 'alki/execution/helpers'

  attr(:children){ {} }

  index do
    update_scope children, data[:prefix], data[:scope]

    data[:overlays] = data[:overlays].inject({}) do |no,(target,overlays)|
      target = target.dup
      if target.empty? || target.shift == key.to_sym
        (no[target]||=[]).push *overlays
      end
      no
    end

    data[:prefix] << key

    children[key]
  end

  output do
    {
      full_scope: update_scope(children, data[:prefix], data[:scope]),
      scope: update_scope(children,data[:prefix]),
      modules: [Alki::Execution::Helpers],
      proc: ->{self}
    }
  end

  def update_scope(children, prefix, scope=nil)
    scope ||= {}
    prefix ||= []
    children.keys.inject(scope) do |h,k|
      h.merge! k => (prefix+[k])
    end
    scope
  end
end
