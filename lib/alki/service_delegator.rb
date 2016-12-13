require 'delegate'

module Alki
  class ServiceDelegator < Delegator
    def initialize(elem,path)
      @elem = elem
      @path = path
    end

    def __getobj__
      @obj ||= @elem.lookup(@path)
    end
  end
end