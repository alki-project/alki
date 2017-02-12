Alki do
  factory :delegate_overlay do
    require 'alki/overlay_delegator'
    -> obj, overlay, **args {
      Alki::OverlayDelegator.new obj, overlay, args
    }
  end

  factory :build_service do
    -> (klass, grp=nil) {
      klass = Alki.load klass
      grp ||= parent
      args = if klass.respond_to? :uses
        klass.uses.map {|path| grp.lookup path }
      else
        []
      end
      klass.new *args
    }
  end
end
