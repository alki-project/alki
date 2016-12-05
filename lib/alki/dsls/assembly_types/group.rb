require 'alki/dsls/assembly'

Alki do
  dsl_method :group do |name,&blk|
    add name, Alki::Dsls::Assembly.build(&blk)[:root]
  end

  element_type :group do
    attr :children, {}
    attr :overlays, []

    index do
      data[:scope] ||= {}
      data[:prefix] ||= []
      update_scope children, data[:prefix], data[:scope]
      data[:prefix] << key

      if overlays
        data[:overlays] = overlays.map do |o|
          o == :clear ? o : {block: o, scope: data[:scope].merge(root: [])}
        end
      end

      children[key]
    end

    output do
      {
        type: :group,
        scope: update_scope(children,data[:prefix]||[],{})
      }
    end

    def update_scope(children, prefix, scope)
      children.keys.inject(scope) do |h,k|
        h.merge! k => (prefix+[k])
      end
      scope
    end
  end
end