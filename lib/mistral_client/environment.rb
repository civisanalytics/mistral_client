module MistralClient
  class Environment < Base
    UNICODE_FIELDS = %w[name scope description].freeze
    JSON_FIELDS = %w[variables].freeze
    BOOL_FIELDS = [].freeze
    PATH = 'environments'.freeze
    include MistralClient::Mixins::MistralObject
    include MistralClient::Mixins::Definable

    def initialize(server, definition = nil, name: nil)
      @server = server
      @definition = parse_definition(definition) if definition
      @name = name
      if @name
        reload
      elsif @definition
        create_environment
      end
    end

    def reload
      super(@name)
    end

    def delete!
      resp = @server.delete("#{PATH}/#{@name}")
      return true if resp.code == 204

      raise MistralClient::MistralError,
            "Could not perform the requested operation:\n#{resp.body}"
    end

    private

    def create_environment
      resp = @server.post(PATH, @definition.to_json, json: true)
      ivars_from_response(resp)
    end

    def massage_definition(definition)
      if definition['variables'].is_a? Hash
        definition['variables'] = definition['variables'].to_json
      end
      definition
    end
  end
end
