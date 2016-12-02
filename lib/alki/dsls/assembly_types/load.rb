require 'alki/support'

Alki do
  dsl_method :load do |group_name,name=group_name.to_s|
    add_load group_name, name
  end

  element_type :load do
    attr :name

    index do
      group.index data, key
    end

    output do
      group.output data
    end

    def group
      unless (data[:loaded]||={})[name]
        path = if data[:load_path]
          File.join(data[:load_path],"#{name}.rb")
        else
          name
        end
        data[:loaded][name] = Alki::Dsl.load(path)[:class].root
      end
      data[:loaded][name]
    end
  end
end