module MistralClient
  class Health < Base
    PATH = ''.freeze

    def initialize(server)
      super()
      @server = server
    end

    def get
      @server.get(PATH.to_s)
    end
  end
end
