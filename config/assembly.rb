Alki do
  factory :delegate_overlay do
    require 'alki/overlay_delegator'
    -> obj, overlay, **args {
      Alki::OverlayDelegator.new obj, overlay, args
    }
  end
end
