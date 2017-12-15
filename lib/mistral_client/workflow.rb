module MistralClient
  class Workflow < Base
    UNICODE_FIELDS = %w[definition input name project_id scope].freeze
    BOOL_FIELDS = [].freeze
    JSON_FIELDS = [].freeze

    PATH = 'workflows'.freeze

    include MistralClient::Mixins::MistralObject
    include MistralClient::Mixins::Definable
    include MistralClient::Mixins::Deletable

    def initialize(server, definition = nil, id: nil, name: nil)
      @server = server
      if definition
        @definition = parse_definition(definition)
        create_workflow
      elsif id || name
        @id = id || name
        reload
      end
    end

    def execute!(env: nil, task_name: nil, input: nil)
      Execution.new(@server,
                    workflow_id: @id,
                    env: env,
                    task_name: task_name,
                    input: input)
    end

    def valid?(definition)
      resp = perform_validation(definition)
      resp['valid']
    end

    def validate(definition)
      resp = perform_validation(definition)
      resp['error']&.split("\n")&.first
    end

    private

    def create_workflow
      resp = @server.post(PATH, @definition)
      if resp['workflows'].length > 1
        raise ConfigurationError,
              'Only one workflow per definition is supported'
      end
      ivars_from_response(resp['workflows'][0])
    end

    def perform_validation(definition)
      @server.post("#{PATH}/validate", parse_definition(definition))
    end
  end
end
