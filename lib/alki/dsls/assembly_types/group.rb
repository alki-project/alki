require 'alki/dsls/assembly'
require 'alki/execution/context'

Alki do
  dsl_method :group do |name,&blk|
    add name, Alki::Dsls::Assembly.build(&blk)[:root]
  end

  element_type :group do
    OverlayInfo = Struct.new(:path,:from,:arg)
    attr :children, {}
    attr :overlays, {}

    index do
      data[:scope] ||= {}
      data[:prefix] ||= []
      update_scope children, data[:prefix], data[:scope]

      data[:overlays]||={}
      if overlays
        overlays.each do |target,overlays|
          (data[:overlays][target]||=[]).push *overlays.map {|(path,arg)|
            OverlayInfo.new(path,data[:prefix].dup,arg)
          }
        end
      end

      data[:overlays] = data[:overlays].inject({}) do |no,(target,overlays)|
        target = target.dup
        if target.empty? || target.shift == key.to_s
          (no[target]||=[]).push *overlays
        end
        no
      end

      data[:prefix] << key

      children[key]
    end

    output do
      {
        scope: update_scope(children,data[:prefix]||[],{}),
        modules: [Alki::Execution::Context],
        proc: ->{self}
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
