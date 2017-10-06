require 'spec_helper'

describe MistralClient::ActionExecution, vcr: true do
  let(:client) do
    MistralClient.new(LOCAL_MISTRAL_URL, verify: false)
  end
  let(:definition) do
    '---
  version: "2.0"
  echo_test:
    type: direct
    tasks:
      echo:
        action: std.echo output="ok"
      async:
        action: std.async_noop
'
  end
  let(:workflow) do
    @workflow_created = true
    client.workflow(definition)
  end
  let(:execution) { workflow.execute! }
  let(:tasks) do
    tasks = []
    count = 0
    while tasks.length < 2
      tasks = client.task.list(workflow_execution_id: execution.id)
      sleep 1 if VCR.current_cassette.recording?
      count += 1
      break if count > 10
    end
    tasks
  end

  let(:async_task) { tasks.find { |t| t.name == 'async' } }
  let(:echo_task) { tasks.find { |t| t.name == 'echo' } }

  after(:each) do
    sleep 1 if VCR.current_cassette&.recording?
    workflow.delete! if @workflow_created
  end

  describe '.list' do
    it 'retrieves action executions' do
      act_exs = client.action_execution.list(task_execution_id: echo_task.id)
      expect(act_exs.count).to eq 1
      expect(act_exs[0].workflow_name).to eq 'echo_test'
      expect(act_exs[0].name).to eq 'std.echo'
    end
  end

  describe '#patch' do
    let(:action_execution) do
      client.action_execution.list(task_execution_id: async_task.id)[0]
    end

    it 'patches the execution' do
      action_execution.patch(state: 'SUCCESS', output: { 'this' => 'that' })
      expect(action_execution.state).to eq('SUCCESS')
      expect(action_execution.output).to eq('result' => { 'this' => 'that' })
    end

    it 'does nothing if there is nothing to patch' do
      allow(client).to receive(:put).and_call_original
      action_execution.patch
      expect(client).not_to have_received(:put)
    end
  end

  context 'shared examples' do
    let(:id) do
      act_exs = client.action_execution.list(task_execution_id: echo_task.id)
      act_exs[0].id
    end
    it_behaves_like 'mistral_object' do
      let(:optional_unicode_fields) { %w[state_info] }
      let(:optional_json_fields) { %w[params] }
    end
  end
end
