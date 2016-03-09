module Alki
  class ServiceDelegator < Delegator
    def initialize(app,path)
      @app = app
      @path = path
    end

    def __getobj__
      @obj ||= @app.lookup(@path)
    end
  end
end