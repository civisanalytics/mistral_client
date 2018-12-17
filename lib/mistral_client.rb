require 'httparty'
require 'yaml'
require 'mistral_client/mixins/definable'
require 'mistral_client/mixins/deletable'
require 'mistral_client/mixins/mistral_object'
require 'mistral_client/base'
require 'mistral_client/action_execution'
require 'mistral_client/client'
require 'mistral_client/environment'
require 'mistral_client/error'
require 'mistral_client/execution'
require 'mistral_client/health'
require 'mistral_client/task'
require 'mistral_client/version'
require 'mistral_client/workflow'

module MistralClient
  class << self
    def new(base = nil, options = {})
      Client.new(base, options)
    end
  end
end
