module Alki
  module Execution
    class OverlayMap
      def initialize(overlays = {})
        @overlays = overlays
      end

      def index(key,tags)
        self.class.new.tap do |new_overlays|
          @overlays.each do |target,overlays|
            target = target.dup
            if target.size == 1 && target[0].to_s.start_with?('%')
              if tags
                tag = target[0].to_s[1..-1].to_sym
                tags.elements_in(tag).each do |path|
                  new_overlays.add path, *overlays
                end
              end
            elsif target.empty? || target.shift == key.to_sym
              new_overlays.add target, *overlays
            end
          end
        end
      end

      def add(path,*overlays)
        @overlays[path] ||= []
        @overlays[path].push *overlays
      end

      def overlays
        overlays = @overlays[[]] || []
        overlays.sort_by(&:order).group_by(&:type)
      end
    end
  end
end
