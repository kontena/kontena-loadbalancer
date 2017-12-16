describe Kontena::Views::HttpIn do

  describe '.render' do
    context 'bind' do
      it 'bings to port 80' do
        output = described_class.render(
          format: :text,
          services: []
        )
        expect(output.match(/bind \*:80/)).to be_truthy
      end

      it 'does not accept proxy protocol by default' do
        output = described_class.render(
          format: :text,
          services: []
        )
        expect(output.match(/accept-proxy/)).to be_falsey
      end

      it 'accepts proxy protocol if env is set' do
        allow(ENV).to receive(:[])
        allow(ENV).to receive(:[]).with('KONTENA_LB_ACCEPT_PROXY').and_return('true')
        output = described_class.render(
          format: :text,
          services: []
        )
        expect(output.match(/accept-proxy/)).to be_truthy
      end

      it 'does not bind to port 443 by default' do
        output = described_class.render(
          format: :text,
          services: []
        )
        expect(output.match(/bind \*:443/)).to be_falsey
      end

      it 'binds to port 443 if SSL certs exist' do
        allow(ENV).to receive(:[])
        allow(ENV).to receive(:[]).with('SSL_CERTS').and_return('certs')
        output = described_class.render(
          format: :text,
          services: []
        )
        expect(output.match(/bind \*:443/)).to be_truthy
      end

      it 'supports http2 if SSL certs exist' do
        allow(ENV).to receive(:[])
        allow(ENV).to receive(:[]).with('SSL_CERTS').and_return('certs')
        output = described_class.render(
          format: :text,
          services: []
        )
        expect(output.match(/alpn h2/)).to be_truthy
      end

      it 'allows to disable http2 support' do
        allow(ENV).to receive(:[])
        allow(ENV).to receive(:[]).with('KONTENA_LB_HTTP2').and_return('false')
        allow(ENV).to receive(:[]).with('SSL_CERTS').and_return('certs')
        output = described_class.render(
          format: :text,
          services: []
        )
        expect(output.match(/alpn h2/)).to be_falsey
      end
    end

    context 'monitor-uri' do
      it 'does not add monitor-uri by default' do
        output = described_class.render(
          format: :text,
          services: []
        )
        expect(output.match(/monitor-uri/)).to be_falsey
      end

      it 'adds monitor-uri if health uri is set' do
        allow(ENV).to receive(:[])
        allow(ENV).to receive(:[]).with('KONTENA_LB_HEALTH_URI').and_return('/__health')
        output = described_class.render(
          format: :text,
          services: []
        )
        expect(output.match(/monitor-uri \/__health/)).to be_truthy
      end
    end
  end
end