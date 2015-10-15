module Alki
  class Settings
    def initialize(environment = nil)
      set :environment, (environment || :development)
    end

    def configure(&blk)
      self.instance_exec(&blk)
    end

    def set(key,value)
      define_singleton_method(key) { value }
    end

    def environment?(*envs)
      envs.include? self.environment and (!block_given? || yield)
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