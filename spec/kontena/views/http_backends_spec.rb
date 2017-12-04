describe Kontena::Views::HttpBackends do

  describe '.render' do
    context 'balance' do
      it 'sets balance to roundrobin by default' do
        services = [
          Kontena::Models::Service.new('foo').tap { |s|
            s.upstreams = [Kontena::Models::Upstream.new('foo-1', '10.81.3.2:8080')]
          }
        ]
        output = described_class.render(
          format: :text,
          services: services
        )
        expect(output.match(/balance roundrobin/)).to be_truthy
      end

      it 'sets balance to configured value' do
        services = [
          Kontena::Models::Service.new('foo').tap { |s|
            s.balance = 'leastconn'
            s.upstreams = [Kontena::Models::Upstream.new('foo-1', '10.81.3.2:8080')]
          }
        ]
        output = described_class.render(
          format: :text,
          services: services
        )
        expect(output.match(/balance leastconn/)).to be_truthy
      end
    end

    context 'cookies' do 
      it 'does not add cookie policy if cookie is not set' do
        services = [
          Kontena::Models::Service.new('foo').tap { |s|
            s.upstreams = [Kontena::Models::Upstream.new('foo-1', '10.81.3.2:8080')]
          }
        ]
        output = described_class.render(
          format: :text,
          services: services,
          tcp_services: []
        )
        expect(output.match(/cookie/)).to be_falsey
      end

      it 'adds default cookie policy if cookie value is empty string' do
        services = [
          Kontena::Models::Service.new('foo').tap { |s|
            s.cookie = ''
            s.upstreams = [Kontena::Models::Upstream.new('foo-1', '10.81.3.2:8080')]
          }
        ]
        output = described_class.render(
          format: :text,
          services: services,
          tcp_services: []
        )
        expect(output.match(/cookie KONTENA_SERVERID insert indirect nocache/)).to be_truthy
      end

      it 'adds custom cookie policy if cookie value is not empty string' do
        services = [
          Kontena::Models::Service.new('foo').tap { |s|
            s.cookie = 'cookie FOO_ID insert indirect nocache'
            s.upstreams = [Kontena::Models::Upstream.new('foo-1', '10.81.3.2:8080')]
          }
        ]
        output = described_class.render(
          format: :text,
          services: services,
          tcp_services: []
        )
        expect(output.match(/cookie FOO_ID insert indirect nocache/)).to be_truthy
      end
    end

    context 'basic auth' do
      it 'adds basic auth config' do 
        services = [
          Kontena::Models::Service.new('foo').tap { |s|
            s.basic_auth_secrets = 'user admin insecure-password passwd'
            s.upstreams = [Kontena::Models::Upstream.new('foo-1', '10.81.3.2:8080')]
          }
        ]
        output = described_class.render(
          format: :text,
          services: services,
          tcp_services: []
        )
        expect(output.match(/http-request auth realm foo/)).to be_truthy
        expect(output.match(/userlist auth_users_foo/)).to be_truthy
        expect(output.match(/user admin insecure-password passwd/)).to be_truthy
      end

      it 'does not add basic auth if basic_auth_secrets is not set' do
        services = [
          Kontena::Models::Service.new('foo').tap { |s|
            s.upstreams = [Kontena::Models::Upstream.new('foo-1', '10.81.3.2:8080')]
          }
        ]
        output = described_class.render(
          format: :text,
          services: services,
          tcp_services: []
        )
        expect(output.match(/http-request auth realm foo/)).to be_falsey
        expect(output.match(/userlist auth_users_foo/)).to be_falsey
      end
    end
  end
end