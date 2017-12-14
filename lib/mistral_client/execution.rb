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

    def initialize(server, workflow_id: nil, env: nil, task_name: nil,
                   id: nil)
      set_attributes(server, workflow_id, env, task_name, id)
      if @id
        reload
      elsif @workflow_id
        create_execution
      end
    end

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

    def set_attributes(server, workflow_id, env, task_name, id, user_params)
      @server = server
      @env = env
      @task_name = task_name
      @id = id
      @workflow_id = workflow_id
      @user_params = user_params
    end

    def create_execution
      body = { workflow_id: @workflow_id }
      params = {}
      params[:env] = @env if @env
      params[:task_name] = @task_name if @task_name
      body[:params] = params unless params.empty?

      resp = @server.post(PATH, body.to_json, json: true)
      ivars_from_response(resp)
    end
  end
end
