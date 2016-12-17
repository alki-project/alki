require 'alki/dsls/assembly_group'
require 'alki/execution/context'

Alki do
  helper :prefix_overlays do |*prefix,overlays|
    overlays.each do |overlay|
      overlay[0].unshift *prefix
    end
    overlays
  end

  helper :update_overlays do |*prefix,overlays|
    ctx[:overlays].push *prefix_overlays(*prefix,overlays)
  end

  dsl_method :group do |name,&blk|
    grp = Alki::Dsls::AssemblyGroup.build(&blk)
    add name, grp[:root]
    update_overlays name, grp[:overlays]
  end

  dsl_method :load do |group_name,name=group_name.to_s|
    grp = Alki::Dsl.load(File.expand_path(name+'.rb',ctx[:config_dir]))[:class]
    add name, grp.root
    update_overlays name, grp.overlays
  end


  element_type :group do
    attr :children, {}

    index do
      data[:scope] ||= {}
      data[:prefix] ||= []
      update_scope children, data[:prefix], data[:scope]

      data[:overlays]||={}

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
        modules: [Alki::Execution::Context],
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
end
