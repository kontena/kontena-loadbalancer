
describe Kontena::Actors::HaproxyConfigGenerator do

  describe '#generate_service' do
    let(:node) do
      double(:node, key: '/foo/bar', children: [
        double(:upstreams, key: '/foo/bar/upstreams', children: [
          double(:a, key: '/foo/bar/upstreams/a', value: 'a:8080'),
          double(:b, key: '/foo/bar/upstreams/b', value: 'b:8080'),
        ])
      ])
    end

    it 'generates a service object with upstreams' do
      service = subject.generate_service(node)
      expect(service.upstreams.size).to eq(2)
    end

    it 'generates service object with balance' do
      node.children << double(:balance, key: "#{node.key}/balance", value: 'leastconn')
      service = subject.generate_service(node)
      expect(service.balance).to eq('leastconn')
    end

    it 'generates service object with virtual_path' do
      node.children << double(:keep_virtual_path, key: "#{node.key}/virtual_path", value: '/api')
      service = subject.generate_service(node)
      expect(service.virtual_path).to eq('/api')
    end

    it 'generates service object with keep_virtual_path' do
      node.children << double(:keep_virtual_path, key: "#{node.key}/keep_virtual_path", value: "true")
      service = subject.generate_service(node)
      expect(service.keep_virtual_path?).to be_truthy
    end

    it 'generates service object with virtual_hosts' do
      virtual_hosts = ['api.domain.com', 'www.domain.com']
      node.children << double(:keep_virtual_hosts, key: "#{node.key}/virtual_hosts", value: virtual_hosts.join(','))
      service = subject.generate_service(node)
      expect(service.virtual_hosts).to eq(virtual_hosts)
    end
  end
end
