Alki do
  require 'alki/execution/value_context'

  attr :block

  output do
    overlays = data[:overlays][[]]||[]
    {
      build: {
        methods: {
          __build__: block
        },
        proc: -> (elem) {
          elem[:value] = overlays.inject(__build__) do |val,(overlay,args)|
            overlay = root.lookup(overlay)
            if !overlay.respond_to?(:call) && overlay.respond_to?(:new)
              overlay = overlay.method(:new)
            end
            overlay.call val, *args
          end
        },
      },
      modules: [Alki::Execution::ValueContext],
      scope: data[:scope],
    }
  end
end
