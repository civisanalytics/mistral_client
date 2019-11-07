require 'spec_helper'

describe MistralClient::Client do
  let(:client) { MistralClient.new('x') }
  let(:client_with_options) do
    MistralClient.new('x', verify: false, timeout: 20)
  end

  let(:success_body) { { 'foo' => 'bar' } }
  let(:success_response) do
    instance_double(HTTParty::Response,
                    body: success_body.to_json,
                    code: 200)
  end

  let(:error_response) do
    instance_double(HTTParty::Response,
                    body: 'problem found',
                    code: 400)
  end

  let(:missing_object_response) do
    instance_double(HTTParty::Response,
                    body: { 'faultstring': 'Invalid object' }.to_json,
                    code: 404)
  end

  describe '#initialize' do
    it 'requires a host' do
      expect { MistralClient.new }
        .to raise_error(MistralClient::ConfigurationError, 'base is required')
      expect { MistralClient.new(nil) }
        .to raise_error(MistralClient::ConfigurationError, 'base is required')
      expect { MistralClient.new('') }
        .to raise_error(MistralClient::ConfigurationError, 'base is required')
    end
  end

  describe '#get' do
    before(:each) do
      allow(HTTParty).to receive(:get) { success_response }
      allow(client).to receive(:check_for_error)
      allow(client_with_options).to receive(:check_for_error)
    end

    it 'parses json responses' do
      expect(client.get('path')).to eq(success_body)
      expect(client).to have_received(:check_for_error).with(success_response)
    end

    it 'forwards options to HTTParty' do
      client_with_options.get('path')
      expect(HTTParty).to have_received(:get)
        .with('x/path', verify: false, timeout: 20)
    end

    it 'forwards default options to HTTParty if no options are specified' do
      client.get('path')
      expect(HTTParty).to have_received(:get).with('x/path', verify: true)
    end
  end

  describe '#post' do
    before(:each) do
      allow(HTTParty).to receive(:post) { success_response }
      allow(client).to receive(:check_for_error)
      allow(client_with_options).to receive(:check_for_error)
    end

    it 'parses json responses' do
      expect(client.post('path', 'body')).to eq(success_body)
      expect(client).to have_received(:check_for_error).with(success_response)
    end

    it 'forwards options to HTTParty' do
      client_with_options.post('path', 'body')
      expect(HTTParty).to have_received(:post)
        .with('x/path', verify: false,
                        timeout: 20,
                        headers: { 'Content-Type' => 'text/plain' },
                        body: 'body')
    end
  end

  describe '#put' do
    before(:each) do
      allow(HTTParty).to receive(:put) { success_response }
      allow(client).to receive(:check_for_error)
      allow(client_with_options).to receive(:check_for_error)
    end

    it 'parses json responses' do
      expect(client.put('path', 'body')).to eq(success_body)
      expect(client).to have_received(:check_for_error).with(success_response)
    end

    it 'forwards options to HTTParty' do
      client_with_options.put('path', 'body')
      expect(HTTParty).to have_received(:put)
        .with('x/path', verify: false,
                        timeout: 20,
                        headers: { 'Content-Type' => 'text/plain' },
                        body: 'body')
    end
  end

  describe '#check_for_error' do
    it 'raises no error for good response' do
      expect do
        client.send(:check_for_error, success_response)
      end.to_not raise_error
    end
    it 'raises MissingObjectError on 404' do
      expect do
        client.send(:check_for_error, missing_object_response)
      end.to raise_error(MistralClient::MissingObjectError, 'Invalid object')
    end
    it 'raises MistralResponseError on non-404 error' do
      expect do
        client.send(:check_for_error, error_response)
      end.to raise_error(MistralClient::MistralResponseError, /problem found/)
    end
  end
end
