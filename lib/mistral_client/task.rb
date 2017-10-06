require 'uri'

module MistralClient
  class Task < Base
    UNICODE_FIELDS = %w[
      workflow_id
      workflow_execution_id
      workflow_name
      state
      state_info
      result
      name
    ].freeze

    JSON_FIELDS = %w[published runtime_context].freeze
    BOOL_FIELDS = %w[reset processed].freeze

    PATH = 'tasks'.freeze

    include MistralClient::Mixins::MistralObject

    def initialize(server, id: nil)
      @server = server
      @path = 'tasks'
      @id = id
      reload if id
    end

    def patch(state: nil, reset: nil, env: nil)
      body = {}
      body[:state] = state if state
      body[:reset] = reset if reset
      body[:env] = env if env

      return if body.empty?

      resp = @server.put("#{PATH}/#{@id}", body.to_json, json: true)
      ivars_from_response(resp)
    end
  end
end
