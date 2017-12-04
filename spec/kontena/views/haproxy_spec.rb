describe Kontena::Views::Haproxy do

  describe '.render' do 
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