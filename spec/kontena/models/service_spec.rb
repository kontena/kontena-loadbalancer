describe Kontena::Models::Service do

  let(:subject) { described_class.new('test-service') }

  describe '#keep_virtual_path?' do
    it 'returns false by default' do
      expect(subject.keep_virtual_path?).to be_falsey
    end

    it 'returns false if keep virtual path is set to invalid value' do
      subject.keep_virtual_path = 'foo'
      expect(subject.keep_virtual_path?).to be_falsey
    end

    it 'returns true if keep virtual path is set' do
      subject.keep_virtual_path = 'true'
      expect(subject.keep_virtual_path?).to be_truthy
    end
  end

  describe '#virtual_hosts?' do 
    it 'returns false by default' do
      expect(subject.virtual_hosts?).to be_falsey
    end

    it 'returns true if virtual hosts are set' do
      subject.virtual_hosts = ['www.domain.com']
      expect(subject.virtual_hosts?).to be_truthy
    end
  end

  describe '#cookie?' do
    it 'returns false by default' do
      expect(subject.cookie?).to be_falsey
    end

    it 'returns true when cookie is set to empty string' do
      subject.cookie = ''
      expect(subject.cookie?).to be_truthy
    end

    it 'returns true when cookie is set' do
      subject.cookie = 'cookie KONTENA_SERVERID insert indirect nocache'
    end
  end

  describe '#custom_settings?' do
    it 'returns false by default' do
      expect(subject.custom_settings?).to be_falsey
    end

    it 'returns true when custom settings' do
      subject.custom_settings = '...'
      expect(subject.custom_settings?).to be_truthy
    end
  end
end