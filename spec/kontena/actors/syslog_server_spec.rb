
describe Kontena::Actors::SyslogServer do

  describe '#handle_data' do
    it 'outputs valid data' do
      data = '<30> daa daa'
      expect(subject).to receive(:puts).with(' daa daa')
      subject.handle_data(data)
    end

    it 'does not output invalid data' do
      data = 'daa daa'
      expect(subject).not_to receive(:puts)
      subject.handle_data(data)
    end
  end
end
