Alki do
  require 'alki/execution/value_helpers'

  attr :block
  output do
    {
      modules: [Alki::Execution::Helpers],
      scope: data[:scope],
      proc: block
    }
  end
end
