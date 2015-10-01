require 'spec_helper_integration'

class Doorkeeper::OAuth::ClientCredentialsRequest
  describe Creator do
    let(:client) { FactoryGirl.create :application }
    let(:scopes) { Doorkeeper::OAuth::Scopes.from_string('public') }

    it 'creates a new token' do
      expect do
        subject.call(client, scopes)
      end.to change { Doorkeeper::AccessToken.count }.by(1)
    end

    context "when reuse_access_token is true" do
      before do
        allow(Doorkeeper.configuration).to receive(:reuse_access_token).and_return(true)
      end

      it 'returns the existing valid token when one exists' do
        existing_token = subject.call(client, scopes)
        existing_token_count = Doorkeeper::AccessToken.count
        result = subject.call(client, scopes)
        expect(Doorkeeper::AccessToken.count).to eq(existing_token_count)
        expect(result).to eq(existing_token)
      end
    end

    context "when reuse_access_token is false" do
      before do
        allow(Doorkeeper.configuration).to receive(:reuse_access_token).and_return(false)
      end

      it 'returns the existing valid token when one exists' do
        subject.call(client, scopes)
        expect do
          subject.call(client, scopes)
        end.to change { Doorkeeper::AccessToken.count }.by(1)
      end
    end

    it 'returns false if creation fails' do
      expect(Doorkeeper::AccessToken).to receive(:find_or_create_for).and_return(false)
      created = subject.call(client, scopes)
      expect(created).to be_falsey
    end
  end
end
