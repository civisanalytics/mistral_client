module MistralClient
  class Execution < Base
    UNICODE_FIELDS = %w[
      workflow_id
      workflow_name
      description
      state
      state_info
    ].freeze

    DATE_FIELDS = %w[created_at updated_at].freeze
    JSON_FIELDS = %w[input output params].freeze
    BOOL_FIELDS = [].freeze

    PATH = 'executions'.freeze

    include MistralClient::Mixins::MistralObject
    include MistralClient::Mixins::Definable
    include MistralClient::Mixins::Deletable

    # rubocop:disable Metrics/ParameterLists
    def initialize(server, workflow_id: nil, env: nil, task_name: nil,
                   id: nil, input: nil)
      super()
      set_attributes(server, workflow_id, env, task_name, id, input)
      if @id
        reload
      elsif @workflow_id
        create_execution
      end
    end
    # rubocop:enable Metrics/ParameterLists

    def patch(description: nil, state: nil, env: nil)
      body = {}
      body[:description] = description unless description.nil?
      body[:state] = state if state
      body[:params] = { env: env } if env

      return if body.empty?

      resp = @server.put("#{PATH}/#{@id}", body.to_json, json: true)
      ivars_from_response(resp)
    end

    private

    # rubocop:disable Metrics/ParameterLists
    def set_attributes(server, workflow_id, env, task_name, id, input)
      @server = server
      @env = env
      @task_name = task_name
      @id = id
      @workflow_id = workflow_id
      @input = input
    end
    # rubocop:enable Metrics/ParameterLists

    def create_execution
      body = { workflow_id: @workflow_id }
      params = {}
      params[:env] = @env if @env
      params[:task_name] = @task_name if @task_name
      body[:params] = params unless params.empty?
      body[:input] = input unless input.nil?

      resp = @server.post(PATH, body.to_json, json: true)
      ivars_from_response(resp)
    end
  end
end
