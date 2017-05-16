module Alki
  module Assembly
    module Meta
      class Tags
        def initialize(tags)
          @tags = tags
        end

        def process(_executor,from,data)
          data[:tags]||={}
          @tags.each do |tag,value|
            (data[:tags][tag.to_sym]||={})[from] = value
          end
        end
      end
    end
  end
end
