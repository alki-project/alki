module Alki
  class Settings
    def set(name,value=nil,&blk)
      if blk
        cache = nil
        define_singleton_method(name.to_sym) do
          cache ||= blk.call
        end
      else
        define_singleton_method(name.to_sym) { value }
      end
    end

    def [](key)
      if respond_to? key
        send key
      else
        nil
      end
    end
  end
end