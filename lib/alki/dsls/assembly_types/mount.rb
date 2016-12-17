require 'alki/override_builder'
require 'alki/support'

Alki do
  require_dsl 'alki/dsls/assembly_types/group'

  dsl_method :mount do |name,pkg=name.to_s,**overrides,&blk|
    klass = Alki::Support.load_class pkg
    mounted_assemblies = klass.overlays.map do |(path,info)|
      [path.dup,info]
    end
    update_overlays name, mounted_assemblies

    overrides = Alki::OverrideBuilder.build overrides, &blk
    update_overlays name, overrides[:overlays]

    add_mount name, klass.root, overrides[:root]
  end

  element_type :mount do
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
        data[:main][:overlays]||={}
        if data[:override][:overlays]
          data[:override][:overlays].each do |target,overlays|
            (data[:main][:overlays][target]||=[]).push *overlays
          end
        end
        data[:override][:overlays]=data[:main][:overlays].dup
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
