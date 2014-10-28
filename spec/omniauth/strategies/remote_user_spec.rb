require 'spec_helper'

describe 'Test Strategy Remote_User' do
	let(:app) do
		Rack::Builder.new do |b|
			b.use Rack::Session::Cookie, :secret => 'abc123'
			b.use OmniAuth::Strategies::RemoteUser#, :fields => [:name, :email], :uid_field => :name
			b.run lambda { |_env| [200, {}, ['Not Found']] }
		end.to_app
	end

	context 'request phase' do
		before(:each) { get '/user/auth/env' }
		it 'displays a form' do
			expect(last_response.status).to eq(200)
		end
	end

end
