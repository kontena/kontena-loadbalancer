describe Kontena::Views::TcpProxies do

  let(:service_class) { Kontena::Models::TcpService }
  let(:upstream_class) { Kontena::Models::Upstream }

  describe '.render' do
    context 'bind' do
      it 'sets accept-proxy if env is set' do
        allow(ENV).to receive(:[]).with('KONTENA_LB_ACCEPT_PROXY').and_return('true')
        services = [
          service_class.new('foo').tap { |s|
            s.external_port = 8080
            s.upstreams = [upstream_class.new('foo-1', '10.81.3.2:8080')]
          }
        ]
        output = described_class.render(
          format: :text,
          services: services
        )
        expect(output.match(/accept-proxy/)).to be_truthy
      end

      it 'does not set accept-proxy without env' do
        services = [
          service_class.new('foo').tap { |s|
            s.external_port = 8080
            s.upstreams = [upstream_class.new('foo-1', '10.81.3.2:8080')]
          }
        ]
        output = described_class.render(
          format: :text,
          services: services
        )
        expect(output.match(/accept-proxy/)).to be_falsey
      end
    end

    context 'balance' do
      it 'sets balance to leastconn by default' do
        services = [
          service_class.new('foo').tap { |s|
            s.external_port = 8080
            s.upstreams = [upstream_class.new('foo-1', '10.81.3.2:8080')]
          }
        ]
        output = described_class.render(
          format: :text,
          services: services
        )
        expect(output.match(/balance leastconn/)).to be_truthy
      end

      it 'sets balance to configured value' do
        services = [
          service_class.new('foo').tap { |s|
            s.balance = 'roundrobin'
            s.external_port = 8080
            s.upstreams = [upstream_class.new('foo-1', '10.81.3.2:8080')]
          }
        ]
        output = described_class.render(
          format: :text,
          services: services
        )
        expect(output.match(/balance roundrobin/)).to be_truthy
      end
    end
  end
end