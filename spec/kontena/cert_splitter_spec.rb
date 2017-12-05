describe Kontena::CertSplitter do
  include FixturesHelper

  let(:ssl_bundle1) { fixture('ssl/bundle1.pem').rstrip }
  let(:ssl_bundle2_invalid) { fixture('ssl/bundle2_invalid.pem').rstrip }
  let(:ssl_test1) { fixture('ssl/test1.pem').rstrip }

  describe '#split_certs' do
    it 'returns an array of strings' do
      expect(subject.split_certs([ssl_bundle1, ssl_bundle2_invalid].join("\n"))).to eq [
        ssl_bundle1.rstrip,
        ssl_bundle2_invalid.rstrip,
      ]
    end

    it 'returns an empty array for an empty string' do
      expect(subject.split_certs('')).to eq []
    end
  end

  describe '#to_h' do
    subject { described_class.new(env) }

    context 'with an empty env' do
      let(:env) { {

      } }

      it 'returns an empty hash' do
        expect(subject.to_h).to eq({})
      end
    end

    context 'with an empty SSL_CERTS env' do
      let(:env) { {
        'SSL_CERTS' => '',
      } }

      it 'returns an empty hash' do
        expect(subject.to_h).to eq({})
      end
    end

    context 'with SSL_CERTS' do
      let(:env) { {
        'SSL_CERTS' => [ssl_bundle1, ssl_bundle2_invalid].join("\n"),
      } }

      it 'returns a hash with the valid cert' do
        expect(subject.to_h).to eq(
          'cert1_gen' => ssl_bundle1,
        )
      end
    end

    context 'with SSL_CERTS + SSL_CERT_*' do
      let(:env) { {
        'SSL_CERTS' => [ssl_bundle1, ssl_bundle2_invalid].join("\n"),
        'SSL_CERT_test1' => ssl_test1,

      } }

      it 'returns a hash with the valid cert' do
        expect(subject.to_h).to eq(
          'cert1_gen' => ssl_bundle1,
          'SSL_CERT_test1' => ssl_test1,
        )
      end
    end

    context 'with SSL_CERT_*' do
      let(:env) { {
        'SSL_CERT_bundle1' => ssl_bundle1,
        'SSL_CERT_bundle2' => ssl_bundle2_invalid,
      } }

      it 'returns a hash with the valid cert' do
        expect(subject.to_h).to eq(
          'SSL_CERT_bundle1' => ssl_bundle1,
        )
      end
    end
  end
end
