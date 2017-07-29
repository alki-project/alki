require 'alki/invalid_path_error'
require 'alki/overlay_info'
require 'alki/execution/overlay_map'

module Alki
  module Assembly
    module Meta
      class Overlay
        def initialize(type,target,overlay,args)
          @type = type
          @target = target
          @overlay = overlay
          @args = args
        end

        def process(executor,from,data)
          data[:total_overlays] ||= 0
          data[:overlays] ||= Execution::OverlayMap.new

          target_path = @target.dup
          if target_path.last.to_s.start_with?('%')
            tag = target_path.pop
          end
          if target_path == []
            target_path = [:root]
          end

          target = executor.canonical_path(from,target_path) or
            raise InvalidPathError.new("Invalid overlay target #{@target.join('.')}")

          target = target.dup.push tag if tag
          overlay = @overlay
          if overlay.is_a?(Array)
            overlay = executor.canonical_path(from,@overlay) or
              raise InvalidPathError.new("Invalid overlay path #{@overlay.join('.')}")
          end
          order = data[:total_overlays]

          data[:overlays].add target, OverlayInfo.new(order,@type, overlay, @args)
          data[:total_overlays] += 1
        end
      end
    end
  end
end
