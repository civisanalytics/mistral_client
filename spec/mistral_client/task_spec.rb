require 'spec_helper'

describe MistralClient::Task, vcr: true do
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
'
  end
  let(:workflow) do
    @workflow_created = true
    client.workflow(definition)
  end
  let(:execution) { workflow.execute! }

  before(:each) { @workflow_created = false }

  after(:each) do
    sleep 1 if VCR.current_cassette&.recording?
    workflow.delete! if @workflow_created
  end

  describe '.list' do
    it 'retrieves tasks' do
      tasks = client.task.list(workflow_execution_id: execution.id)
      expect(tasks.count).to eq 1
      expect(tasks[0].workflow_execution_id).to eq execution.id
      expect(tasks[0].name).to eq 'echo'
    end
  end

  describe 'shared examples' do
    let(:id) do
      tasks = client.task.list(workflow_execution_id: execution.id)
      tasks[0].id
    end
    it_behaves_like 'mistral_object' do
      let(:optional_unicode_fields) { %w[state_info] }
      let(:optional_json_fields) { %w[runtime_context] }
      let(:optional_bool_fields) { %w[reset] }
    end
  end

  describe '#patch' do
    let(:failing_definition) do
      '---
    version: "2.0"
    echo_test:
      type: direct
      tasks:
        echo:
          action: std.fail
  '
    end
    let(:failing_workflow) do
      @failing_workflow_created = true
      client.workflow(failing_definition)
    end
    let(:failing_execution) { failing_workflow.execute! }
    let(:failing_task) do
      tasks = client.task.list(workflow_execution_id: failing_execution.id)
      sleep 5 if VCR.current_cassette&.recording?
      tasks[0]
    end

    after(:each) do
      sleep 1 if VCR.current_cassette&.recording?
      failing_workflow.delete! if @failing_workflow_created
    end

    it 'patches the task' do
      failing_task.patch(state: 'RUNNING', reset: true)
      expect(failing_task.state).to eq('RUNNING')
    end

    it 'does nothing if there is nothing to patch' do
      allow(client).to receive(:put).and_call_original
      failing_task.patch
      expect(client).not_to have_received(:put)
    end
  end
end
