module MistralClient
  class MistralError < StandardError; end

  class ConfigurationError < MistralError; end

  class MissingObjectError < MistralError; end

  class MistralResponseError < MistralError
    attr_reader :response

    def initialize(response)
      @response = response
      super(response)
    end
  end
end
