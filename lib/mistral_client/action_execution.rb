module MistralClient
  class ActionExecution < Base
    UNICODE_FIELDS = %w[
      description
      name
      state
      state_info
      task_execution_id
      task_name
      workflow_name
    ].freeze

    JSON_FIELDS = %w[input output params].freeze
    BOOL_FIELDS = %w[accepted].freeze

    PATH = 'action_executions'.freeze

    include MistralClient::Mixins::MistralObject

    def initialize(server, id: nil)
      @server = server
      @path = 'action_executions'
      @id = id
      reload if @id
    end

    def patch(state: nil, output: nil)
      body = {}
      body[:state] = state unless state.nil?
      body[:output] = output unless output.nil?
      return if body.empty?

      resp = @server.put("#{PATH}/#{@id}", body.to_json, json: true)
      ivars_from_response(resp)
    end
  end
end
