require 'alki/execution/helpers'
require 'alki/overlay_delegator'
require 'alki/reloadable_delegator'

module Alki
  module Execution
    module ValueHelpers
      include Helpers

      def delegate_overlay(obj,overlay,**args)
        Alki::OverlayDelegator.new(obj,overlay,args)
      end

      def entrypoint(klass,*args, reloadable: false)
        klass.new *args.map {|a| reloadable ? self.reloadable(a) : lookup(a) }
      end

      def reloadable(path)
        Alki::ReloadableDelegator.new(root.assembly_instance,meta[:building],path)
      end
    end
  end
end
