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
        methods[:initialize] = {
          body: -> (executor, meta) {
            @__executor__ = executor
            @__meta__ = meta
            @__cache__ = {}
          }
        }
        methods[:__execute__] = {
          body: -> (name, path,args,blk) {
            obj = @__executor__.execute @__meta__, path, args, blk
            obj = __process_reference__ name, obj if respond_to?(:__process_reference__,true)
            obj
          }
        }
        (config[:scope]||{}).each do |name,path|
          methods[name] = {
            body:->(*args,&blk) {
               __execute__ name, path, args, blk
            }
          }
          methods[:"__raw_#{name}__"] = {
            body:->(*args,&blk) {
              @__executor__.execute @__meta__, path, args, blk
            },
            private: true
          }
        end
        (config[:methods]||{}).each do |name,body|
          methods[name] = {
            body: body,
            private: true,
          }
        end
        ClassBuilder.build(
          modules: config[:modules],
          instance_methods: methods,
        )
      end
    end
  end
end
