Alki do
  factory :delegate_overlay do
    require 'alki/overlay_delegator'
    -> obj, overlay, **args {
      Alki::OverlayDelegator.new obj, overlay, args
    }
  end

  factory :build_service do
    -> (klass, grp=nil, args=[]) {
      klass = Alki.load klass
      grp ||= parent
      if klass.respond_to? :uses
        args += klass.uses.map {|path| grp.lookup path }
      end
      klass.new *args
    }
  end
end
