describe Kontena::AcmeChallenges do
  let(:challenge_token) { 'LoqXcYV8q5ONbJQxbmR7SCTNo3tiAXDfowyjxAjEuX0' }
  let(:key_authorization) { 'LoqXcYV8q5ONbJQxbmR7SCTNo3tiAXDfowyjxAjEuX0.9jg46WB3rR_AHD-EBXdN7cBkH1WOu0tA3M9fm21mqTI' }

  subject { described_class.new(
    challenge_token => key_authorization,
  ) }

  describe '#configured?' do
    let(:env) { { } }

    before do
      allow(described_class).to receive(:env).and_return(env)
    end

    context 'with an empty env' do
      it 'is false' do
        expect(described_class.configured?).to be_falsey
      end
    end

    context 'with non-challenge envs' do
      let(:env) { { 'FOO' => 'bar' } }

      it 'is false' do
        expect(described_class.configured?).to be_falsey
      end
    end

    context 'with challenge envs' do
      let(:env) { { "ACME_CHALLENGE_#{challenge_token}" => key_authorization } }

      it 'is true' do
        expect(described_class.configured?).to be_truthy
      end
    end
  end

  describe '#boot' do
    it 'loads nothing from env empty env' do
      challenges = described_class.boot({})

      expect(challenges.challenges?).to be_falsey
    end

    it 'loads challenge from ACME_CHALLENGE_*' do
      challenges = described_class.boot({"ACME_CHALLENGE_#{challenge_token}" => key_authorization})

      expect(challenges.challenges).to eq(challenge_token => key_authorization)
    end
  end

  describe '#respond' do
    it 'returns nil for a non-existant challenge' do
      expect(subject.respond('foo')).to be_nil
    end

    it 'returns the key authorization for a known challenge' do
      expect(subject.respond(challenge_token)).to eq key_authorization
    end
  end
end
