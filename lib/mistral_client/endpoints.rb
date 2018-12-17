module MistralClient
  class Endpoints < Base
    PATH = ''.freeze

    def initialize(server)
      @server = server
    end

    def get
      @server.get(PATH.to_s)
    end
  end
end
