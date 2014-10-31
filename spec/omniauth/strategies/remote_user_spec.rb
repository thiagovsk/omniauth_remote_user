require 'spec_helper'

describe 'Test Strategy Remote_User' do
	let(:app) do
		Rack::Builder.new do |b|
			b.use Rack::Session::Cookie, :secret => 'abc123'
			b.use OmniAuth::Strategies::RemoteUser, :fields => [:name, :email], :uid_field => :name
			b.run  lambda { |_env| [200, {'HTTP_REMOTE_USER' => 'myuser'}, ['My body']] }
		end.to_app
	end

	context 'request phase' do
		before(:each) { get '/auth/remote_user',{},{'HTTP_COOKIE' => '_gitlab_session=user@myuser','HTTP_REMOTE_USER' => "user@myuser" }}
		it 'check rack response' do
			expect(last_response.body).to eq('My body')
			expect(last_response.status).to eq(200)
			expect(last_response.original_headers).to eq({'HTTP_REMOTE_USER' => 'myuser' })
			expect(last_response.errors).to eq('')
		end
		it 'check my env request' do
			expect(last_request.env['HTTP_COOKIE']).to eq("_gitlab_session=user@myuser")
			expect(last_request.env['HTTP_REMOTE_USER']).to eq("user@myuser")
			expect(last_request.request_method).to eq("GET")
			expect(last_request.path_info).to eq("/auth/remote_user")
		end
	end


end
