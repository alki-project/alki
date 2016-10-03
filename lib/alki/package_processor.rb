module Alki
  class PackageProcessor
    def lookup(package,path)
      lookup_path(package,path)
    end

    private

    def lookup_path(desc, path, data = {})
      data_defaults data
      path = path.dup
      update_data data, desc
      until path.empty?
        key = path.shift
        data[:prefix] += [key]
        elem = desc[key]
        if !elem
          return nil
        else
          unless path.empty?
            if elem[:type] == :group
              desc = elem[:children]
              update_data data, desc
            elsif elem[:type] == :package
              return package_lookup_path elem, path, data
            else
              raise "Invalid path"
            end
          end
        end
      end
      if elem
        case elem[:type]
          when :group
            {type: :group, children: prefix_keys(elem[:children], data[:prefix])}
          when :package
            children = prefix_keys([elem[:children],elem[:overrides]], data[:prefix])
            {type: :group, children: children}
          when :service, :factory
            last_clear = data[:overlays].rindex(:clear)
            overlays = last_clear ? data[:overlays][(last_clear + 1)..-1] : data[:overlays]
            {type: elem[:type], block: elem[:block], overlays: overlays, scope: data[:scope]}
          else
            raise "Invalid elem type: #{elem[:type]}"
        end
      else
        {type: :group, children: prefix_keys(desc,data[:prefix])}
      end
    end

    def package_lookup_path(elem,path,data)
      if path[0] == :orig
        if path.size == 1
          {type: :group, children: prefix_keys(elem[:children],data[:prefix]+[:orig])}
        else
          lookup_path(elem[:children],path[1..-1],data.merge(scope:nil))
        end
      else
        override_scope = data[:scope].merge(pkg: data[:prefix]+[:orig])
        override_data = data.merge(overlays: data[:overlays].dup, scope: override_scope)
        lookup_path(merge_overlays(elem[:overrides],elem[:children]), path, override_data) or
            lookup_path(
                merge_overrides(elem[:children], elem[:overrides]),
                path, data.merge(scope: nil)
            )
      end
    end

    def data_defaults(data)
      data[:overlays] ||= []
      data[:prefix] ||= []
      data[:scope] ||= {root: data[:prefix]}
    end

    def prefix_keys(source, prefix, result={})
      source = [source] unless source.is_a? Array
      source.inject([]){|a,h| a|=h.keys}.inject(result) do |h,k|
        h.merge! k => (prefix+[k])
      end
      result
    end

    def update_data(data,desc)
      prefix_keys desc, data[:prefix], data[:scope]
      if desc['overlays']
        data[:overlays].push *desc['overlays'].map { |o|
          o == :clear ? o : {block: o, scope: data[:scope]}
        }
      end
    end

    def merge_overlays(a,b)
      updates = {}
      b.keys.each do |k|
        if k == 'overlays'
          updates[k] = (a[k] || []) + b[k]
        elsif a.key? k
          val = merge_item_overlays(a[k],b[k])
          updates[k] = val unless a[k].equal? val
        end
      end
      if updates.empty?
        a
      else
        a.merge updates
      end
    end

    def merge_item_overlays(a,b)
      if a[:children] && b[:children]
        if b[:type] == :package
          b_children = merge_overlays(b[:children],b[:overrides])
        elsif b[:type] == :group
          b_children = b[:children]
        end
        if a[:type] == :package
          a.merge(overrides: merge_overlays(a[:overrides],b_children))
        elsif b[:type] == :group
          a.merge(children: merge_overlays(a[:children],b_children))
        end
      else
        a
      end
    end

    def merge_overrides(a,b)
      updates = {}
      b.keys.each do |k|
        if a.key? k
          if k == 'overlays'
            updates[k] = b[k] + a[k]
          else
            val = merge_item(a[k],b[k])
            updates[k] = val unless a[k].equal? val
          end
        else
          updates[k] = b[k]
        end
      end
      if updates.empty?
        a
      else
        a.merge updates
      end

    end

    def merge_item(a,b)
      if a[:children] && b[:children]
        if b[:type] == :package
          b_children = merge_overrides(b[:children],b[:overrides])
        elsif b[:type] == :group
          b_children = b[:children]
        end
        if a[:type] == :package
          a.merge(overrides: merge_overrides(a[:overrides],b_children))
        elsif b[:type] == :group
          a.merge(children: merge_overrides(a[:children],b_children))
        end
      elsif a != b
        b
      else
        a
      end
    end
  end
end