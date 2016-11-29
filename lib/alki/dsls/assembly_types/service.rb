Alki do
  dsl_method :set do |name,value=nil,&blk|
    add_service name, :service, (blk || -> { value })
  end

  dsl_method :service do |name,&blk|
    add_service name, :service, blk
  end

  dsl_method :factory do |name,&blk|
    add_service name, :factory, blk
  end

  element_type :service do
    attr :type
    attr :block

    output do
      last_clear = data[:overlays].rindex(:clear)
      overlays = last_clear ? data[:overlays][(last_clear + 1)..-1] : data[:overlays]
      scope = data[:scope].merge root: []
      {type: type, block: block, overlays: overlays, scope: scope}
    end
  end
end