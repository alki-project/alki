module Alki
  module Execution
    class TagMap
      def initialize(tag_map = {})
        @tag_map = tag_map
      end

      def add(path,tags)
        tags.each do |tag,value|
          @tag_map[tag] ||= {}
          @tag_map[tag][path] = value
        end
      end

      def elements_in(tag)
        @tag_map[tag]&.keys || []
      end

      def index(key)
        new_tag_map = {}
        @tag_map.each do |tag,tagged|
          tagged.each do |path,value|
            if path.empty? || path[0] == key.to_sym
              new_tag_map[tag] ||= {}
              new_path = path[1..-1] || []
              new_tag_map[tag][new_path] = value
            end
          end
        end
        self.class.new new_tag_map
      end

      def tags
        Hash.new.tap do |tags|
          @tag_map.each do |tag,tagged|
            tags[tag] = tagged[[]]
          end
        end
      end
    end
  end
end
