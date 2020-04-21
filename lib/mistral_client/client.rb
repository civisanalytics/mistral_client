module MistralClient
  class Client
    DEFAULT_HTTP_OPTIONS = { verify: true }.freeze

    def initialize(base, options = {})
      raise ConfigurationError, 'base is required' if base.to_s.empty?

      @base = base
      @http_options = DEFAULT_HTTP_OPTIONS.merge(options)
    end

    def delete(path)
      HTTParty.delete("#{@base}/#{path}", @http_options)
    end

    def get(path)
      resp = HTTParty.get("#{@base}/#{path}", @http_options)
      check_for_error(resp)
      JSON.parse(resp.body)
    end

    def post(path, body, json: false)
      post_or_put(:post, path, body, json)
    end

    def put(path, body, json: false)
      post_or_put(:put, path, body, json)
    end

    def self.resources
      {
        action_execution: MistralClient::ActionExecution,
        environment: MistralClient::Environment,
        execution: MistralClient::Execution,
        health: MistralClient::Health,
        task: MistralClient::Task,
        workflow: MistralClient::Workflow
      }
    end

    def method_missing(name, *args, &block)
      if self.class.resources.keys.include?(name)
        self.class.resources[name].new(self, *args)
      else
        super
      end
    end

    def respond_to_missing?(name, include_private = false)
      self.class.resources.keys.include?(name) || super
    end

    private

    def post_or_put(verb, path, body, json)
      raise ArgumentError unless %i[post put].include?(verb)

      headers = if json
                  { 'Content-Type' => 'application/json' }
                else
                  { 'Content-Type' => 'text/plain' }
                end
      options = @http_options.merge(headers: headers, body: body)
      resp = HTTParty.send(verb, "#{@base}/#{path}", options)
      check_for_error(resp)
      JSON.parse(resp.body)
    end

    def check_for_error(resp)
      return if resp.code >= 200 && resp.code < 300
      if resp.code == 404
        raise MissingObjectError, JSON.parse(resp.body)['faultstring']
      end

      raise MistralResponseError.new(resp),
            "Could not perform the requested operation:\n#{resp.body}"
    end
  end
end
