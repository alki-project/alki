module Alki
  module Assembly
    module Meta
      class Tags
        def initialize(tags)
          @tags = tags
        end

        def process(_executor,from,data)
          data[:tags]||={}
          @tags.each do |tag|
            (data[:tags][tag.to_sym]||=[]) << from
          end
        end
      end
    end
  end
end
