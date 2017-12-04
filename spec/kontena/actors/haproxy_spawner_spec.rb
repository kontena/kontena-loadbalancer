
describe Kontena::Actors::HaproxySpawner do

  describe '#update_haproxy' do
    it 'does not start or update haproxy if config is invalid' do
      allow(subject).to receive(:validate_config).and_return(false)
      expect(subject).not_to receive(:start_haproxy)
      expect(subject).not_to receive(:reload_haproxy)
      subject.update_haproxy
    end

    it 'starts haproxy if config is valid and haproxy is not yet running' do
      allow(subject).to receive(:children).and_return([])
      allow(subject).to receive(:validate_config).and_return(true)
      expect(subject).to receive(:start_haproxy)
      expect(subject).not_to receive(:reload_haproxy)
      subject.update_haproxy
    end

    it 'reloads haproxy if config is valid and haproxy is already running' do
      allow(subject).to receive(:validate_config).and_return(true)
      allow(subject).to receive(:children).and_return([1])
      expect(subject).not_to receive(:start_haproxy)
      expect(subject).to receive(:reload_haproxy)
      subject.update_haproxy
    end
  end
end
