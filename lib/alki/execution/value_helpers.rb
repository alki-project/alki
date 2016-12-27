require 'alki/execution/helpers'
require 'alki/overlay_delegator'

module Alki
  module Execution
    module ValueHelpers
      include Helpers

      def delegate_overlay(obj,overlay,**args)
        Alki::OverlayDelegator.new(obj,overlay,args)
      end
    end
  end
end
