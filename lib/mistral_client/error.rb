module MistralClient
  class MistralError < StandardError; end

  class ConfigurationError < MistralError; end
  class MissingObjectError < MistralError; end
end
