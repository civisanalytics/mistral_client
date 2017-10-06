require 'spec_helper'

describe MistralClient::Environment, vcr: true do
  let(:client) do
    MistralClient.new(LOCAL_MISTRAL_URL, verify: false)
  end
  let(:definition) do
    'name: test
variables:
  output: environment_test
'
  end
  let(:environment) do
    @environment_created = true
    client.environment(definition)
  end

  after(:each) do
    sleep 1 if VCR.current_cassette&.recording?
    environment.delete! if @environment_created
  end

  describe '#initialize' do
    it 'creates an environment from a definition' do
      expect(environment.id).not_to be nil
    end
    it 'sets instance vars based on an environment name' do
      env = MistralClient::Environment.new(client, name: environment.name)
      expect(env.id).not_to be nil
      expect(env.variables['output']).to eq('environment_test')
    end
  end

  describe 'shared_examples' do
    after(:each) { @environment_created = false }
    it_behaves_like 'deletable' do
      let(:obj) { environment }
    end
  end

  describe '#list!' do
    it 'lists environments' do
      environment
      envs = client.environment.list
      expect(envs.class).to be Array
      expect(envs[0].class).to be MistralClient::Environment
    end
  end
end
