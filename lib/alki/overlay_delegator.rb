module Alki
  class OverlayDelegator
    def initialize(obj,overlay)
      @obj = obj
      @overlay = overlay
    end

    def respond_to_missing(method,include_private = false)
      if @overlay.respond_to? :overlay_respond_to?
        @overlay.overlay_respond_to? @obj, method, include_private
      else
        @obj.respond_to? method, include_private
      end
    end

    def method_missing(method,*args,&blk)
      @overlay.call @obj, method, *args, &blk
    end
  end
end