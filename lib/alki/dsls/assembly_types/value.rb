require 'alki/execution/value_context'

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
        value: value
      }
    end
  end

  element_type :proc_value do
    attr :proc

    output do
      {
        build: {
          methods: {
            __build__: proc
          },
          proc: ->(desc) {desc[:value] = __build__}
        },
        modules: [Alki::Execution::ValueContext],
        scope: data[:scope]
      }
    end
  end

  element_type :service do
    attr :block

    output do
      overlays = data[:overlays][[]]||[]
      {
        build: {
          methods: {
            __build__: block
          },
          proc: -> (elem) {
            elem[:value] = overlays.inject(__build__) do |val,info|
              overlay = root.lookup(*info.from).lookup(*info.path)
              if !overlay.respond_to?(:call) && overlay.respond_to?(:new)
                overlay = overlay.method(:new)
              end
              if info.arg
                overlay.call val, info.arg
              else
                overlay.call val
              end
            end
          },
        },
        modules: [Alki::Execution::ValueContext],
        scope: data[:scope],
      }
    end
  end

  element_type :factory do
    attr :block
    output do
      {
        modules: [Alki::Execution::ValueContext],
        scope: data[:scope],
        build: {
          methods: {
            __build__: block
          },
          proc: ->(desc) {
            desc[:methods] = {
              __create__: __build__
            }
            desc[:proc] = ->(*args,&blk) {
              if !args.empty? || blk
                __create__ *args, &blk
              else
                method(:__create__)
              end
            }
          }
        }
      }
    end
  end

  element_type :func do
    attr :block
    output do
      {
        modules: [Alki::Execution::ValueContext],
        scope: data[:scope],
        proc: block
      }
    end
  end
end
