require 'alki/settings'

module Alki
  class ApplicationSettings < Settings
    def initialize(environment = nil)
      set :environment, (environment || :development)
    end

    def configure(&blk)
      self.instance_exec(&blk)
    end

    def environment?(*envs)
      envs.include? self.environment and (!block_given? || yield)
    end
  end
end