Alki do
  require 'alki/overlay_info'

  dsl_method :overlay do |target,overlay,*args|
    (ctx[:overlays]||=[]) << [
      [],
      Alki::OverlayInfo.new(
        target.to_s.split('.').map(&:to_sym),
        overlay.to_s.split('.').map(&:to_sym),
        args
      )
    ]
  end
end
