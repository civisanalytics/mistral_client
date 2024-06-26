shared_examples 'deletable' do
  let(:obj) { described_class.new(client, id:) }
  describe '#delete!' do
    it 'calls mistral succesfully' do
      sleep 1 if VCR.current_cassette.recording?
      expect(obj.delete!).to be(true)
    end
  end
end
