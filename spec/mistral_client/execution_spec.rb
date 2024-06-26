require 'spec_helper'

describe MistralClient::Execution, vcr: true do
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

  let(:env_def) { { 'name' => 'test', 'variables' => { 'foo' => 'bar' } } }

  let(:definition_with_input) do
    '---
  version: "2.0"
  echo_test_with_input:
    type: direct
    input:
      - key
    tasks:
      echo:
        action: std.echo output="ok"
    '
  end

  let(:input) { { 'key' => 'value' } }
  let(:workflow_with_input) do
    @workflow_with_input_created = true
    client.workflow(definition_with_input)
  end
  let(:env_def_with_input) do
    { 'name' => 'test_with_input', 'variables' => { 'foo' => 'bar' } }
  end

  before(:each) do
    @workflow_created = false
    @workflow_with_input_created = false
  end

  after(:each) do
    sleep 1 if VCR.current_cassette&.recording?
    workflow.delete! if @workflow_created
    workflow_with_input.delete! if @workflow_with_input_created
  end

  describe '#initialize' do
    context 'for a direct workflow' do
      context 'with a workflow_id' do
        it 'creates a new execution and stores id' do
          allow_any_instance_of(MistralClient::Execution)
            .to receive(:create_execution).and_call_original
          ex = MistralClient::Execution.new(client, workflow_id: workflow.id)
          expect(ex.id).not_to be nil
          expect(ex).to have_received(:create_execution)
        end
      end

      context 'with an execution id' do
        let(:id) { workflow.execute!.id }

        it 'does not create an execution' do
          allow_any_instance_of(MistralClient::Execution).to receive(:reload)
          ex = MistralClient::Execution.new(client, id:)
          expect(ex.id).to eq(id)
        end
      end

      context 'with an environment' do
        let!(:env) { MistralClient::Environment.new(client, env_def.to_yaml) }

        after(:each) do
          env.delete!
        end

        it 'creates an execution using the environment' do
          ex = MistralClient::Execution.new(
            client,
            workflow_id: workflow.id,
            env: env_def['name']
          )
          expect(ex.params['env']).to eq(env_def['variables'])
        end
      end

      context 'with an environment and an input' do
        let!(:env) do
          MistralClient::Environment.new(client, env_def_with_input.to_yaml)
        end

        after(:each) do
          env.delete!
        end

        it 'creates an execution using the environment and the input' do
          ex = MistralClient::Execution.new(
            client,
            workflow_id: workflow_with_input.id,
            env: env_def_with_input['name'],
            input:
          )
          expect(ex.input).to eq(input)
        end
      end
    end

    context 'for a reverse workflow' do
      let(:definition) do
        '---
      version: "2.0"
      echo_test:
        type: reverse
        tasks:
          echo:
            action: std.echo output="ok"
    '
      end

      context 'with a target task name' do
        it 'creates an execution using the target task name' do
          ex = MistralClient::Execution.new(
            client,
            workflow_id: workflow.id,
            task_name: 'echo'
          )
          expect(ex.params['task_name']).to eq('echo')
        end

        it 'errors if the target task name is not in the definition' do
          expect do
            MistralClient::Execution.new(
              client,
              workflow_id: workflow.id,
              task_name: 'not_echo'
            )
          end.to raise_error(MistralClient::MistralError)
        end
      end

      context 'with an environment and target task name' do
        let!(:env) { MistralClient::Environment.new(client, env_def.to_yaml) }

        after(:each) do
          env.delete!
        end

        it 'creates an execution using the environment and target task name' do
          ex = MistralClient::Execution.new(
            client,
            workflow_id: workflow.id,
            env: env_def['name'],
            task_name: 'echo'
          )
          expect(ex.params['env']).to eq(env_def['variables'])
          expect(ex.params['task_name']).to eq('echo')
        end
      end
    end
  end

  describe '#reload' do
    let(:id) { workflow.execute!.id }

    it_behaves_like 'mistral_object' do
      let(:optional_unicode_fields) { %w[state_info] }
    end
    it_behaves_like 'deletable'
  end

  describe '#patch' do
    let(:execution) { workflow.execute! }

    it 'patches the execution' do
      execution.patch(state: 'CANCELLED')
      expect(execution.state).to eq('CANCELLED')
    end

    it 'does nothing if there is nothing to patch' do
      allow(client).to receive(:put).and_call_original
      execution.patch
      expect(client).not_to have_received(:put)
    end
  end
end
