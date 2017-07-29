require 'concurrent/immutable_struct'
module Alki
  Overrides = Concurrent::ImmutableStruct.new(:root,:meta)
end
