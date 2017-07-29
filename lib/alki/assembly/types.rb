module Alki
  module Assembly
    module Types
      def self.build(type,*args)
        Alki.load("alki/assembly/types/#{type}").new *args
      end
    end
  end
end
