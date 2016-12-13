require 'alki/execution/context'
require 'alki/overlay_delegator'

module Alki
  module Execution
    module ValueContext
      include Context

      def delegate_overlay(obj,overlay,**args)
        Alki::OverlayDelegator.new(obj,overlay,args)
      end
    end
  end
end
