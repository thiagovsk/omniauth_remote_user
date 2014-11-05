require 'spec_helper'

describe 'Test Strategy Remote_User' do
	let(:app) do
		Rack::Builder.new do |b|
			b.use Rack::Session::Cookie, :secret => 'abc123'
			b.use OmniAuth::Strategies::RemoteUser
			b.run  lambda { |_env| [200, {}, ['My body']] }
		end.to_app
	end

	context 'Without REMOTE_USER and not logged in' do
		 before(:each){get '/', {}, {}}

		it 'Do nothing' do
			last_response.status.should == 200
			last_response.cookies['_remote_user'] == nil
		end
	end

	context 'Without REMOTE_USER and logged in' do
		#Logout current user
		

	end

	context 'With REMOTE_USER and not logged in' do
		#Login REMOTE_USER
		it 'logs user in' do
			get '/', {}, { 'HTTP_REMOTE_USER' => 'foobar' }
		end
	end

	context 'With REMOTE_USER, logged in and current user equals REMOTE_USER' do
		#do nothing

	end

	context 'With REMOTE_USER, logged in and current user not equals REMOTE_USER' do
		#Logout current user and login REMOTE_USER

	end
end

