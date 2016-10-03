module Alki
  class OverlayDelegator
    def initialize(name,obj,overlay)
      @name = name
      @obj = obj
      @overlay = overlay
      @key = :"#{obj.object_id}:#{overlay.object_id}"
    end

    def respond_to_missing(method,include_private = false)
      unless Thread.current[@key]
        Thread.current[@key] = true
        if @overlay.respond_to? :overlay_respond_to?
          @overlay.overlay_respond_to? @obj, method, include_private
        else
          @obj.respond_to? method, include_private
        end
        Thread.current[@key] = false
      end
    end

    def method_missing(method,*args,&blk)
      if Thread.current[@key]
        res = @obj.send method, *args, &blk
      else
        Thread.current[@key] = true
        res = @overlay.call @name, @obj, method, *args, &blk
        Thread.current[@key] = false
      end
      res
    end
  end
end