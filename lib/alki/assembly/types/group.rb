Alki do
  require 'ostruct'
  require 'alki/execution/helpers'

  attr(:children){ {} }

  index do
    update_scope children, data[:prefix], data[:scope]

    data[:tags] ||= {}
    data[:tags] = data[:tags].inject({}) do |tags,(tag,tagged)|
      tagged.each do |path,value|
        if path.empty? || path[0] == key.to_sym
          (tags[tag]||={})[(path[1..-1]||[])] = value
        end
      end
      tags
    end

    data[:overlays] ||= {}
    data[:overlays] = data[:overlays].inject({}) do |no,(target,overlays)|
      target = target.dup
      if target.size == 1 && target[0].to_s.start_with?('%')
        tags = data[:tags][target[0].to_s[1..-1].to_sym]
        if tags
          tags.keys.each do |path|
            (no[path]||=[]).push *overlays
          end
        end
      elsif target.empty? || target.shift == key.to_sym
        (no[target]||=[]).push *overlays
      end
      no
    end

    data[:prefix] << key

    children[key]
  end

  output do
    children_names = children.keys.map(&:to_sym)
    {
      full_scope: update_scope(children, data[:prefix], data[:scope]),
      scope: update_scope(children,data[:prefix]),
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
