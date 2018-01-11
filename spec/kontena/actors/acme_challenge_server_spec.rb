describe Kontena::Actors::AcmeChallengeServer do
  let(:acme_challenges) { instance_double(Kontena::AcmeChallenges) }

  subject { described_class.new(acme_challenges,
    webrick_options: { :DoNotListen => true },
  ) }
  let(:server) { subject.instance_variable_get('@server') }

  describe 'HTTP' do
    let(:http_request) { instance_double(WEBrick::HTTPRequest,
      request_method: http_method,
      unparsed_uri: http_path,
      path: WEBrick::HTTPUtils::normalize_path(http_path),
    ) }
    let(:http_response) { WEBrick::HTTPResponse.new(server.config) }

    before do
      # XXX: should not be mocking the WEBrick::HTTPRequest
      allow(http_request).to receive(:script_name=)
      allow(http_request).to receive(:path_info=)
    end

    context 'GET /' do
      let(:http_method) { 'GET' }
      let(:http_path) { '/' }

      it 'responds with HTTP 404' do
        expect{server.service(http_request, http_response)}.to raise_error(WEBrick::HTTPStatus::NotFound)
      end
    end

    context 'GET /.well-known/acme-challenge' do
      let(:http_method) { 'GET' }
      let(:http_path) { '/.well-known/acme-challenge' }

      it 'responds with HTTP 404' do
        expect{server.service(http_request, http_response)}.to raise_error(WEBrick::HTTPStatus::NotFound)
      end
    end

    context 'GET /.well-known/acme-challenge/:token' do
      let(:acme_token) { 'LoqXcYV8q5ONbJQxbmR7SCTNo3tiAXDfowyjxAjEuX0' }
      let(:acme_authorization) { 'LoqXcYV8q5ONbJQxbmR7SCTNo3tiAXDfowyjxAjEuX0.9jg46WB3rR_AHD-EBXdN7cBkH1WOu0tA3M9fm21mqTI' }
      let(:http_method) { 'GET' }
      let(:http_path) { "/.well-known/acme-challenge/#{acme_token}" }

      context 'with a matching ACME_CHALLENGE' do
        before do
          expect(acme_challenges).to receive(:respond).with(acme_token).and_return(acme_authorization)
        end

        it 'responds with HTTP 200' do
          server.service(http_request, http_response)

          expect(http_response.status).to eq 200
          expect(http_response.body).to eq acme_authorization
        end
      end

      context 'without any matching ACME_CHALLENGE' do
        before do
          expect(acme_challenges).to receive(:respond).with(acme_token).and_return(nil)
        end

        it 'responds with HTTP 440' do
          server.service(http_request, http_response)

          expect(http_response.status).to eq 404
        end
      end
    end
  end
end
