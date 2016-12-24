Alki do
  require 'alki/execution/value_helpers'

  attr :proc

  output do
    {
      build: {
        methods: {
          __build__: proc
        },
        proc: ->(desc) {desc[:value] = __build__}
      },
      modules: [Alki::Execution::ValueHelpers],
      scope: data[:scope]
    }
  end
end
