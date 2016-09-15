module Alki
  class PackageProcessor
    def lookup(package,path)
      lookup_path(package,path)
    end

    private

    def prefix_keys(source, prefix, result={})
      source = [source] unless source.is_a? Array
      source.inject([]){|a,h| a|=h.keys}.inject(result) do |h,k|
        h.merge! k => (prefix+[k])
      end
      result
    end

    def lookup_path(desc, path, prefix=[], scope={root: prefix})
      path = path.dup
      prefix_keys desc, prefix, scope
      until path.empty?
        key = path.shift
        prefix += [key]
        elem = desc[key]
        if !elem
          return nil
        else
          unless path.empty?
            if elem[:type] == :group
              desc = elem[:children]
              prefix_keys elem[:children], prefix, scope
            elsif elem[:type] == :package
              return package_lookup_path elem, path, prefix, scope
            else
              raise "Invalid path"
            end
          end
        end
      end
      if elem
        case elem[:type]
          when :group
            {type: :group, children: prefix_keys(elem[:children], prefix)}
          when :package
            children = prefix_keys([elem[:children],elem[:overrides]],prefix)
            {type: :group, children: children}
          when :service, :factory
            {type: elem[:type], block: elem[:block], scope: scope}
          else
            raise "Invalid elem type: #{elem[:type]}"
        end
      else
        {type: :group, children: prefix_keys(desc,prefix)}
      end
    end

    def package_lookup_path(elem,path,prefix,parent_scope={})
      if path[0] == :orig
        if path.size == 1
          {type: :group, children: prefix_keys(elem[:children],prefix+[:orig])}
        else
          lookup_path(elem[:children],path[1..-1],prefix)
        end
      else
        override_scope = parent_scope.merge(pkg: prefix+[:orig])
        lookup_path(elem[:overrides], path, prefix, override_scope) or
            lookup_path(
                merge_overrides(elem[:children], elem[:overrides]),
                path, prefix
            )
      end
    end

    def merge_overrides(a,b)
      updates = {}
      b.keys.each do |k|
        if a.key? k
          val = merge_item(a[k],b[k])
          updates[k] = val unless a[k].equal? val
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