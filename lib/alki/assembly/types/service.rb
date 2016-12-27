Alki do
  require 'alki/execution/value_helpers'

  attr :block

  output do
    overlays = (data[:overlays][[]]||[]).group_by(&:first)
    value_overlays = overlays[:value]||[]
    reference_overlays = overlays[:reference]||[]
    methods = {
      __build__: block,
      __apply_overlays__: -> obj, overlays {
        overlays.inject(obj) do |val,(_,overlay,args)|
          overlay = __raw_root__.lookup(overlay) if overlay.is_a?(Array)
          if !overlay.respond_to?(:call) && overlay.respond_to?(:new)
            overlay = overlay.method(:new)
          end
          overlay.call val, *args
        end
      }
    }
    unless reference_overlays.empty?
      methods[:__process_reference__] = -> ref {
        __apply_overlays__ ref, reference_overlays
      }
    end
    {
      build: {
        methods: methods,
        proc: -> (elem) {
          elem[:value] = __apply_overlays__ __build__, value_overlays
        },
      },
      modules: [Alki::Execution::ValueHelpers],
      scope: data[:scope],
    }
  end
end
