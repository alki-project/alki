require 'alki/override_builder'
require 'alki/support'

Alki do
  require_dsl 'alki/dsls/assembly_types/group'
  require_dsl 'alki/dsls/assembly_types/value'

  dsl_method :assembly do |name,pkg=name.to_s,**overrides,&blk|
    klass = Alki::Support.load_class pkg
    config_dir = klass.assembly_options[:load_path]
    config_dir = build_value config_dir if config_dir
    overrides = Alki::OverrideBuilder.build overrides, &blk

    add_assembly name, klass.root, config_dir, overrides
  end

  element_type :assembly do
    attr :root
    attr :config_dir
    attr :overrides, nil

    index do
      if key == :config_dir
        data.merge! main_data
        config_dir
      elsif key == :original
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
      add_parent_path output[:scope]
      output[:scope][:config_dir] = (data[:prefix]||[]) + [:config_dir]
      output[:scope][:original] = (data[:prefix]||[]) + [:original]
      output[:scope].merge! overrides.output(data)[:scope] if overrides
      output
    end

    def override_data
      od = data.dup
      od[:scope] ||= {}
      od[:scope].merge! original: ((data[:prefix]||[]) + [:original])
      od
    end

    def main_data
      assembly_path = data[:prefix] ? data[:prefix].dup : []
      scope = {assembly: assembly_path, root: [], config_dir: (assembly_path + [:config_dir])}
      add_parent_path scope
      {scope: scope, overlays: {}}
    end

    def add_parent_path(scope)
      parent_path = (data[:scope]||{})[:assembly]||nil
      scope[:parent] = parent_path if parent_path
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
