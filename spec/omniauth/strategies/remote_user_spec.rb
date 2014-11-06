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
		before(:each){
			clear_cookies        
			set_cookie "_gitlab_session=foobar"
			set_cookie "_remote_user=foobar"
			get '/', {}, { 'HTTP_REMOTE_USER' => 'foobar2' }
		}

		it 'Logout current user and login REMOTE_USER' do
			expect(last_request.cookies['_gitlab_session']).to eq('foobar')
			expect(last_request.cookies['_remote_user']).to eq('foobar')
			expect(last_response.status).to eq(302)			
			expect(last_response['Set-Cookie']).to eq('_remote_user=foobar2')	
		end
	end

	context 'Verify omniauth hash with REMOTE_USER_DATA' do
		before(:each){
			clear_cookies
			post '/auth/remoteuser/callback', {}, { 'HTTP_REMOTE_USER' => 'foobar', 
									'HTTP_REMOTE_USER_DATA' => JSON.dump({'name' => 'foobar', 'email' => 'foobar@test.com'})}
		}

		it 'Verify uid' do
			expect(last_request.env['omniauth.auth']['uid']).to eq('foobar')
		end

		it 'Verify info' do
			expect(last_request.env['omniauth.auth']['info']['nickname']).to eq('foobar')
			expect(last_request.env['omniauth.auth']['info']['email']).to eq('foobar@test.com')
		end
	end

	context 'Verify omniauth.auth info without REMOTE_USER_DATA' do
		before(:each){
			clear_cookies
			post '/auth/remoteuser/callback', {}, { 'HTTP_REMOTE_USER' => 'foobar' } 
		}

		it 'Verify uid' do
			expect(last_request.env['omniauth.auth']['uid']).to eq('foobar')
		end

		it 'Verify info' do
			expect(last_request.env['omniauth.auth']['info']).to eq({})
		end
	end
end

