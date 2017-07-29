Alki do
  require 'ostruct'
  require 'alki/execution/helpers'

  attr(:children){ {} }

  index do
    update_scope children, data[:prefix], data[:scope]

    if data[:tags]
      data[:tags] = data[:tags].index key
    end

    if data[:overlays]
      data[:overlays] = data[:overlays].index key, data[:tags]
    end

    data[:prefix] << key

    children[key]
  end

  output do
    children_names = children.keys.map(&:to_sym)
    {
      lookup_methods: update_scope(children,data[:prefix]),
      scope: update_scope(children, data[:prefix], data[:scope]),
      modules: [Alki::Execution::Helpers],
      methods: {
        children: -> {
          children_names
        },
      },
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
