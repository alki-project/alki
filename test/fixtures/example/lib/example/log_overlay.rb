module Example
  class LogOverlay
    def initialize(log)
      @log = log
    end

    def overlay_send(obj,info,method,*args,&blk)
      @log << "Calling #{info[:name]}##{method} #{args.join(", ")}\n"
      obj.public_send method, *args, &blk
    end
  end
end
