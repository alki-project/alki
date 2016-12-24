Alki do
  require 'alki/execution/value_helpers'

  attr :block

  output do
    {
      modules: [Alki::Execution::ValueHelpers],
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
