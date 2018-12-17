require 'spec_helper'

describe MistralClient::Health, vcr: true do
  let(:client) do
    MistralClient.new(LOCAL_MISTRAL_URL, verify: false)
  end

  after(:each) do
    sleep 1 if VCR.current_cassette&.recording?
  end

  describe '.get' do
    it 'retrieves application root' do
      expect { client.health.get }.not_to raise_error
    end
  end
end
