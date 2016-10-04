class LogOverlay
  def initialize(log)
    @log = log
  end

  def overlay_send(name,obj,method,*args,&blk)
    @log << "Calling #{name}##{method} #{args.join(", ")}\n"
    obj.public_send method, *args, &blk
  end
end