Alki do
  dsl_method :set do |name,value=nil,&blk|
    if blk
      add_proc_value name, blk
    else
      add_value name, value
    end
  end

  dsl_method :service do |name,&blk|
    add_service name, blk
  end

  dsl_method :factory do |name,&blk|
    add_factory name, blk
  end

  dsl_method :func do |name,&blk|
    add_func name, blk
  end

  element_type :value do
    attr :value

    output do
      {
        type: :value,
        block: ->(_) {
          val = value
          ->{ val }
        },
        scope: {}
      }
    end
  end

  element_type :proc_value do
    attr :proc

    output do
      {
        type: :value,
        block: ->(e) {
          val = e.call proc
          ->{ val }
        },
        scope: data[:scope]
      }
    end
  end

  element_type :service do
    attr :block
    output do
      last_clear = data[:overlays].rindex(:clear)
      overlays = last_clear ? data[:overlays][(last_clear + 1)..-1] : data[:overlays]
      {
        type: :value,
        block: -> (evaluator) {
          svc = evaluator.call block
          -> { svc }
        },
        scope: data[:scope],
        overlays: overlays
      }
    end
  end

  element_type :factory do
    attr :block
    output do
      {
        type: :value,
        block: -> (evaluator) {
          factory = evaluator.call block
          -> (*args,&blk) {
            factory.call *args, &blk
          }
        },
        scope: data[:scope]
      }
    end
  end

  element_type :func do
    attr :block
    output do
      {
        type: :value,
        block: ->(evaluator) {
          value_blk = block
          -> (*args,&blk) {
            evaluator.call(value_blk,*args,&blk)
          }
        },
        scope: data[:scope]
      }
    end
  end
end