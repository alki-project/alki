Alki do
  dsl_method :overlay do |&blk|
    (ctx[:overlays]||=[]) << blk
  end

  dsl_method :clear_overlays do
    (ctx[:overlays]||=[]) << :clear
  end
end