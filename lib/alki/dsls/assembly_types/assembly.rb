require 'alki/support'

Alki do
  require_dsl 'alki/dsls/assembly_types/group'

  dsl_method :assembly do |name,pkg=name.to_s,&blk|
    klass = Alki::Support.load_class pkg

    elem = if blk
      build_assembly klass.root, build_group_dsl(blk)
    else
      klass.root
    end
    add name, elem
  end

  element_type :assembly do
    attr :root
    attr :overrides, nil

    index do
      if overrides
        data.replace(
          main: data.merge(main_data),
          override: data.dup,
        )
        override.index data, key
      else
        root.index data.merge!(main_data), key
      end
    end

    output do
      scope = root.output(data)[:scope]
      scope.merge! overrides.output(data)[:scope] if overrides
      {
        type: :group,
        scope: scope,
      }
    end

    def main_data
      pkg = data[:prefix] ? data[:prefix].dup : []
      {scope: {pkg: pkg, root: []}, overlays: []}
    end

    def override
      Alki::AssemblyTypes::Override.new root, overrides
    end
  end

  element_type :override do
    attr :main
    attr :override

    index do
      main_child = main.index data[:main], key
      override_child = override.index data[:override], key

      if main_child && override_child
        (data[:main][:scope]||={}).merge! (data[:override][:scope]||{})
        (data[:main][:overlays]||=[]).push *(data[:override][:overlays]||[])
        Alki::AssemblyTypes::Override.new main_child, override_child
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
end