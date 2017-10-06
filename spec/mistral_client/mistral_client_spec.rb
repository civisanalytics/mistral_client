require 'spec_helper'

describe MistralClient do
  it 'can create a client' do
    expect(MistralClient.new('https://mistral.local/v2'))
      .to be_an_instance_of(MistralClient::Client)
  end
end
