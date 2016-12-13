Alki do
  dsl_method :overlay do |target,*overlays,**args|
    ((ctx[:overlays]||={})[target.to_s.split('.')]||=[]).push *overlays.map{ |o|
      [o.to_s.split('.'),args.empty? ? nil : args]
    }
  end
end