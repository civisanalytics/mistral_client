shared_examples 'mistral_object' do
  let(:optional_bool_fields) { [] }
  let(:optional_date_fields) { %w[updated_at] }
  let(:optional_json_fields) { [] }
  let(:optional_unicode_fields) { [] }
  let(:obj) { described_class.new(client, id:) }

  describe '#reload' do
    it 'sets instance variables' do
      allow_any_instance_of(described_class)
        .to receive(:reload).and_call_original
      expect(obj).to have_received(:reload)
      expect(obj.id).to eq id

      (described_class::UNICODE_FIELDS - optional_unicode_fields).each do |f|
        expect(obj.send(f)).not_to be_nil, f
      end
      (described_class::DATE_FIELDS - optional_date_fields).each do |f|
        expect(obj.send(f).class).to be(DateTime), f
      end
      (described_class::JSON_FIELDS - optional_json_fields).each do |f|
        expect(obj.send(f).class).to be(Hash), f
      end
      (described_class::BOOL_FIELDS - optional_bool_fields).each do |f|
        expect(obj.send(f)).to be(true).or(be(false)), "#{f}: #{obj.send(f)}"
      end
    end
  end

  describe '#list' do
    let!(:obj_id) { id }
    it 'retrieves objects' do
      allow_any_instance_of(described_class)
        .to receive(:list).and_call_original
      objs = described_class.new(client).list
      expect(objs.class).to be(Array)
      expect(objs[0].class).to be(described_class)
    end
  end
end
