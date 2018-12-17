require 'spec_helper'

describe MistralClient::Health, vcr: true do
  let(:client) do
    MistralClient.new(LOCAL_MISTRAL_URL, verify: false)
  end

  after(:each) do
    sleep 1 if VCR.current_cassette&.recording?
  end

  describe '.get' do
    it 'retrieves available endpoints' do
      endpoints = client.endpoints.get
      expect(endpoints.count).to eq 1
    end
  end
end
