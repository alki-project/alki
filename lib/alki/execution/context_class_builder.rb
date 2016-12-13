require 'alki/class_builder'

module Alki
  module Execution
    module ContextClassBuilder
      def self.build(config)
        if config[:body]
          methods = {
            __call__: {body: (config[:body])},
            meta: {body: ->{@__meta__}}
          }
        else
          methods = {}
        end
        (config[:scope]||{}).each do |name,path|
          methods[name] = {
            body:->(*args,&blk) {
              @__executor__.execute @__meta__, path, args, blk
            }
          }
        end
        (config[:methods]||{}).each do |name,body|
          methods[name] = {
            body: body,
            private: true,
          }
        end
        ClassBuilder.build(
          initialize_params: [:__executor__,:__meta__],
          modules: config[:modules],
          instance_methods: methods,
        )
      end
    end
  end
end
