Alki do
  require 'alki/execution/value_context'

  attr :block
  output do
    {
      modules: [Alki::Execution::ValueContext],
      scope: data[:scope],
      proc: block
    }
  end
end
