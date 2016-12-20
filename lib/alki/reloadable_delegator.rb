require 'delegate'

module Alki
  class ReloadableDelegator < Delegator
    def initialize(instance,from,path)
      @instance = instance
      @from = from.to_s.split('.').map(&:to_sym)
      @path = path.to_s.split('.').map(&:to_sym)
    end

    def __getobj__
      @instance.assembly_executor.call(
        @instance.assembly_executor.canonical_path(@from,@path)
      )
    end
  end
end
