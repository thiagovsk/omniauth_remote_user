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
		before(:each){
			get '/', {}, {}
		}

		it 'Do nothing' do
			expect(last_response.status).to eq(200)
			expect(last_request.cookies['_remote_user']).to eq(nil)
			expect(last_request.cookies['_gitlab_session']).to eq(nil)
		end
	end

	context 'Without REMOTE_USER and logged in' do
		before(:each){
			clear_cookies        
			set_cookie "_gitlab_session=test"
			set_cookie "_remote_user=test"
			get '/', {}, {}
		}
		
		it 'Logout curreent user' do
			cookie_session_str = "_gitlab_session=; max-age=0; expires=Thu, 01 Jan 1970 00:00:00 -0000" <<
				"\n_remote_user=; max-age=0; expires=Thu, 01 Jan 1970 00:00:00 -0000"
			expect(last_request.cookies['_gitlab_session']).to eq('test')
			expect(last_request.cookies['_remote_user']).to eq('test')
			expect(last_response.status).to eq(302)
			expect(last_response['Set-Cookie']).to eq(cookie_session_str)
		end
	end

	context 'With REMOTE_USER and not logged in' do
		before(:each){
			get '/', {}, { 'HTTP_REMOTE_USER' => 'foobar' }
		}

		it 'logs REMOTE_USER in' do
			expect(last_response.status).to eq(302)			
			expect(last_response['Set-Cookie']).to eq('_remote_user=foobar')
		end
	end

	context 'With REMOTE_USER, logged in and current user equals REMOTE_USER' do
		before(:each){
			clear_cookies        
			set_cookie "_gitlab_session=foobar"
			set_cookie "_remote_user=foobar"
			get '/', {}, { 'HTTP_REMOTE_USER' => 'foobar' }
		}

		it 'Do nothing' do
			cookie_session_str = "_gitlab_session=foobar\n_remote_user=foobar"
			expect(last_request.cookies['_gitlab_session']).to eq('foobar')
			expect(last_request.cookies['_remote_user']).to eq('foobar')
			expect(last_response.status).to eq(200)			
			expect(last_response['Set-Cookie']).to eq(nil)	
		end
	end

	context 'With REMOTE_USER, logged in and current user not equals REMOTE_USER' do
		#Logout current user and login REMOTE_USER

	end
end

