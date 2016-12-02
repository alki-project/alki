Alki do
  dsl_method :set do |name,value=nil,&blk|
    add_value name, false, -> (evaluator) {
      val = if blk
         evaluator.call blk
      else
        value
      end
      -> { val }
    }
  end

  dsl_method :service do |name,&blk|
    add_value name, true, -> (evaluator) {
      svc = evaluator.call blk
      -> { svc }
    }
  end

  dsl_method :factory do |name,&blk|
    add_value name, false, -> (evaluator) {
      factory = evaluator.call blk
      -> (*args,&blk) {
        factory.call *args, &blk
      }
    }
  end

  dsl_method :func do |name,&value_blk|
    add_value name, false, -> (evaluator) {
      -> (*args,&blk) {
        evaluator.call(value_blk,*args,&blk)
      }
    }
  end

  element_type :value do
    attr :apply_overlays
    attr :block

    output do
      result  = {
        type: :value,
        block: block,
        scope: data[:scope].merge(root: [])
      }
      if apply_overlays
        last_clear = data[:overlays].rindex(:clear)
        result[:overlays] =  last_clear ? data[:overlays][(last_clear + 1)..-1] : data[:overlays]
      end
      result
    end
  end
end