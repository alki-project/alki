Alki do
  require 'alki/execution/value_helpers'
  require 'alki/execution/factory'

  attr :block

  output do
    {
      modules: [Alki::Execution::Helpers],
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
              Alki::Execution::Factory.new method(:__create__)
            end
          }
        }
      }
    }
  end
end
