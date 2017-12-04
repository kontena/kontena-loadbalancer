describe Kontena::Actors::HaproxyConfigWriter do
  let(:parent) { double(:parent) }

  before(:each) do
    allow(subject).to receive(:parent).and_return(parent)
    allow(subject).to receive(:write_config)
  end

  describe '#update_config' do
    it 'writes config on first call' do
      expect(subject).to receive(:write_config).once
      expect(parent).to receive(:<<).once
      subject.update_config('updated config')
    end

    it 'does not write config when config has no changes' do
      expect(subject).to receive(:write_config).once
      expect(parent).to receive(:<<).once
      2.times do 
        subject.update_config('updated config')
      end
    end
  end
end
