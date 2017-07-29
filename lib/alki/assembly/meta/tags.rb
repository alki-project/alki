require 'alki/execution/tag_map'

module Alki
  module Assembly
    module Meta
      class Tags
        def initialize(tags)
          @tags = tags
        end

        def process(_executor,from,data)
          data[:tags]||=Execution::TagMap.new
          data[:tags].add from, @tags
        end
      end
    end
  end
end
