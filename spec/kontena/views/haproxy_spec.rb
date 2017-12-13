describe Kontena::Views::Haproxy do

  describe '.render' do
    context 'http-in' do
      it 'does not configure http-in by default' do
        output = described_class.render(
          format: :text,
          services: [],
          tcp_services: []
        )
        expect(output.match(/listen http-in/)).to be_falsey
      end

      it 'configures http-in if health uri is defined' do
        allow(ENV).to receive(:[])
        allow(ENV).to receive(:[]).with('KONTENA_LB_HEALTH_URI').and_return('/__health')
        output = described_class.render(
          format: :text,
          services: [],
          tcp_services: []
        )
        expect(output.match(/listen http-in/)).to be_truthy
      end

      it 'configures http-in if ssl certs' do
        allow(ENV).to receive(:[])
        allow(ENV).to receive(:[]).with('SSL_CERTS').and_return('cert...')
        output = described_class.render(
          format: :text,
          services: [],
          tcp_services: []
        )
        expect(output.match(/listen http-in/)).to be_truthy
      end
    end
    context 'stats' do
      it 'configures stats auth' do
        allow(ENV).to receive(:[])
        allow(ENV).to receive(:[]).with('STATS_PASSWORD').and_return('secrettzzz')
        output = described_class.render(
          format: :text,
          services: [],
          tcp_services: []
        )
        expect(output.match(/userlist stats-auth/)).to be_truthy
        expect(output.match(/user stats insecure-password secrettzzz/))
      end
    end
  end
end