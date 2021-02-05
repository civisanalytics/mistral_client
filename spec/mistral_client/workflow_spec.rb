require 'spec_helper'

describe MistralClient::Workflow, vcr: true do
  let(:client) do
    MistralClient.new(LOCAL_MISTRAL_URL, verify: false)
  end
  let(:workflow) do
    @workflow_created = true
    client.workflow(definition)
  end

  after(:each) do
    sleep 1 if VCR.current_cassette&.recording?
    # rubocop:disable Lint/SuppressedException
    begin
      workflow.delete! if @workflow_created
    rescue MistralClient::MistralError
    end
    # rubocop:enable Lint/SuppressedException
  end

  before(:each) { allow(MistralClient::Execution).to receive(:new) }

  RSpec.shared_examples 'the workflow is valid' do
    describe '#valid?' do
      it 'validates a string workflow' do
        expect(client.workflow.valid?(definition)).to be true
      end

      it 'validates a hash workflow' do
        hash_wf = YAML.safe_load(definition, aliases: true)
        expect(client.workflow.valid?(hash_wf)).to be true
      end
    end

    it '#validate' do
      expect(client.workflow.validate(definition)).to be nil
    end

    it '#initialize' do
      expect(workflow.id).not_to be nil
    end

    it '#execute!' do
      workflow.execute!
      expect(MistralClient::Execution)
        .to have_received(:new)
        .with(client,
              workflow_id: workflow.id,
              env: nil,
              task_name: nil,
              input: nil)
    end
  end

  context 'with a valid definition' do
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

    it_behaves_like 'the workflow is valid'

    context 'with an environment' do
      it '#execute!' do
        workflow.execute!(env: 'test')
        expect(MistralClient::Execution)
          .to have_received(:new)
          .with(client,
                workflow_id: workflow.id,
                env: 'test',
                task_name: nil,
                input: nil)
      end
    end

    context 'with an existing workflow' do
      describe 'by id' do
        let(:wf_by_id) do
          client.workflow(id: workflow.id)
        end

        it '#initialize!' do
          expect(wf_by_id.id).to eq(workflow.id)
        end
      end

      describe 'by name' do
        let(:wf_by_name) do
          workflow
          client.workflow(name: 'echo_test')
        end

        it '#initialize!' do
          expect(wf_by_name.name).to eq('echo_test')
        end
      end

      describe 'shared examples' do
        let(:id) { workflow.id }
        it_behaves_like 'mistral_object' do
          let(:optional_unicode_fields) { %w[state_info] }
        end
        it_behaves_like 'deletable'
      end
    end
  end

  context 'with a valid definition of a reverse workflow' do
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

    it_behaves_like 'the workflow is valid'

    context 'with an environment and target task name' do
      it '#execute!' do
        workflow.execute!(env: 'test', task_name: 'echo')
        expect(MistralClient::Execution)
          .to have_received(:new)
          .with(client,
                workflow_id: workflow.id,
                env: 'test',
                task_name: 'echo',
                input: nil)
      end
    end
  end

  context 'with a valid definition containing aliases' do
    let(:definition) do
      '---
  version: "2.0"
  echo_test:
    type: direct
    tasks:
      echo: &def
        action: std.echo output="ok"
      echo2: *def
'
    end

    it_behaves_like 'the workflow is valid'
  end

  context 'with an invalid definition' do
    let(:definition) do
      '---
  version: "2.0"
  echo_test:
    type: direct
'
    end

    it '#valid?' do
      expect(client.workflow.valid?(definition)).to be false
    end

    it '#validate' do
      expect(client.workflow.validate(definition))
        .to eq("Invalid DSL: 'tasks' is a required property")
    end
  end
end
