require 'alki/support'

Alki do
  dsl_method :load do |group_name,name=group_name.to_s|
    add_load group_name, ctx[:prefix], name
  end

  element_type :load do
    attr :prefix
    attr :name

    index do
      group.index data, key
    end

    output do
      group.output data
    end

    def group
      unless (data[:loaded]||={})[name]
        if data[:load_path]
          require File.join(data[:load_path],name)
        else
          require name
        end
        prefixed_name = if prefix
          File.join(prefix,name)
        else
          name
        end
        data[:loaded][name] = Alki::Support.load_class(prefixed_name).root
      end
      data[:loaded][name]
    end
  end
end