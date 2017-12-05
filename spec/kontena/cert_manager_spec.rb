describe Kontena::CertManager do
  include FixturesHelper

  let(:ssl_bundle1) { fixture('ssl/bundle1.pem').rstrip }
  let(:ssl_bundle2_invalid) { fixture('ssl/bundle2_invalid.pem').rstrip }
  let(:ssl_test1) { fixture('ssl/test1.pem').rstrip }

  subject { described_class.new(
    'cert1_gen' => ssl_bundle1,
    'SSL_CERT_test1' => ssl_test1,
  ) }

  describe '#boot' do
    it 'does nothing with an empty env' do
      expect_any_instance_of(described_class).to_not receive(:setup)
      expect_any_instance_of(described_class).to_not receive(:write_cert)

      described_class.boot({})
    end

    it 'does nothing with an empty SSL_CERTS' do
      expect_any_instance_of(described_class).to_not receive(:setup)
      expect_any_instance_of(described_class).to_not receive(:write_cert)

      described_class.boot({ 'SSL_CERTS' => '' })
    end

    it 'setups and writes with SSL_CERTS' do
      expect_any_instance_of(described_class).to receive(:setup)
      expect_any_instance_of(described_class).to receive(:write_cert).with('cert1_gen', ssl_bundle1)

      described_class.boot({ 'SSL_CERTS' => ssl_bundle1 + "\n" + ssl_bundle2_invalid })
    end

    it 'setups and writes with SSL_CERTS + SSL_CERT_*' do
      expect_any_instance_of(described_class).to receive(:setup)
      expect_any_instance_of(described_class).to receive(:write_cert).with('cert1_gen', ssl_bundle1)
      expect_any_instance_of(described_class).to receive(:write_cert).with('SSL_CERT_test1', ssl_test1)

      described_class.boot({ 'SSL_CERTS' => ssl_bundle1 + "\n" + ssl_bundle2_invalid, 'SSL_CERT_test1' => ssl_test1, })
    end

    it 'setups and writes with SSL_CERT_*' do
      expect_any_instance_of(described_class).to receive(:setup)
      expect_any_instance_of(described_class).to receive(:write_cert).with('SSL_CERT_bundle1', ssl_bundle1)
      expect_any_instance_of(described_class).to receive(:write_cert).with('SSL_CERT_test1', ssl_test1)

      described_class.boot({ 'SSL_CERT_bundle1' => ssl_bundle1, 'SSL_CERT_test1' => ssl_test1, })
    end
  end

  describe '#write_certs' do
    it 'writes each cert if valid' do
      expect(subject).to receive(:write_cert).once.with('cert1_gen', ssl_bundle1)
      expect(subject).to receive(:write_cert).once.with('SSL_CERT_test1', ssl_test1)

      subject.write_certs
    end
  end
end
