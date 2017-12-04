describe Kontena::Views::TcpProxies do

  let(:service_class) { Kontena::Models::TcpService }
  let(:upstream_class) { Kontena::Models::Upstream }

  describe '.render' do
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