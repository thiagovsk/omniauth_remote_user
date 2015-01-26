require 'spec_helper'

describe 'Test Strategy Remote_User' do
  let(:app) do
    Rack::Builder.new do |b|
      b.use Rack::Session::Cookie, :secret => 'abc123'
      b.use OmniAuth::Strategies::RemoteUser
      b.run  lambda { |_env| [200, {}, ['My body']] }
    end.to_app
  end

  context 'Without HTTP_REMOTE_USER and not logged in' do
    before(:each){
      get '/', {}, {}
    }

    it 'Do nothing' do
      expect(last_response.status).to eq(200)
      expect(last_request.cookies['_remote_user']).to eq(nil)
    end
  end

  context 'Without HTTP_REMOTE_USER and logged in' do
    before(:each){
      clear_cookies
      set_cookie "_remote_user=test"
      get '/', {}, {}
    }

    it 'Logout curreent user' do
      expect(last_request.cookies['_remote_user']).to eq('test')
      expect(last_response.status).to eq(302)
      expect(last_response['Set-Cookie']).to include("_remote_user=")
      expect(last_response['Set-Cookie']).to include("path=")
    end
  end

  context 'With HTTP_REMOTE_USER and not logged in' do
    before(:each){
      get '/', {}, { 'HTTP_REMOTE_USER' => 'foobar' }
    }

    it 'logs HTTP_REMOTE_USER in' do
      expect(last_response.status).to eq(302)
      expect(last_response['Set-Cookie']).to include('_remote_user=foobar')
      expect(last_response['Set-Cookie']).to include('path=')
    end
  end

  context 'With HTTP_REMOTE_USER, logged in and current user equals HTTP_REMOTE_USER' do
    before(:each){
      clear_cookies
      set_cookie "_remote_user=foobar"
      get '/', {}, { 'HTTP_REMOTE_USER' => 'foobar' }
    }

    it 'Do nothing' do
      expect(last_request.cookies['_remote_user']).to eq('foobar')
      expect(last_response.status).to eq(200)
      expect(last_response['Set-Cookie']).to eq(nil)
    end
  end

  context 'With HTTP_REMOTE_USER, logged in and current user not equals HTTP_REMOTE_USER' do
    before(:each){
      clear_cookies
      set_cookie "_remote_user=foobar"
      get '/', {}, { 'HTTP_REMOTE_USER' => 'foobar2' }
    }

    it 'Logout current user and login HTTP_REMOTE_USER' do
      expect(last_request.cookies['_remote_user']).to eq('foobar')
      expect(last_response.status).to eq(302)
    end
  end

  context 'Verify omniauth hash with HTTP_REMOTE_USER_DATA' do
    before(:each){
      clear_cookies
      set_cookie "_remote_user=foobar"
      post '/auth/RemoteUser/callback', {}, { 'HTTP_REMOTE_USER' => 'foobar',
                                              'HTTP_REMOTE_USER_DATA' => JSON.dump({'name' => 'foobar barfoo', 'email' => 'foobar@test.com'})}
    }

    it 'Verify uid' do
      expect(last_request.env['omniauth.auth']['uid']).to eq('foobar')
    end

    it 'Verify info' do
      expect(last_request.env['omniauth.auth']['info']['nickname']).to eq('foobar')
      expect(last_request.env['omniauth.auth']['info']['email']).to eq('foobar@test.com')
      expect(last_request.env['omniauth.auth']['info']['lastname']).to eq('barfoo')
      expect(last_request.env['omniauth.auth']['info']['firstname']).to eq('foobar')
    end
  end

  context 'Verify omniauth.auth info without HTTP_REMOTE_USER_DATA' do
    before(:each){
      clear_cookies
      set_cookie "_remote_user=foobar"
      post '/auth/RemoteUser/callback', {}, { 'HTTP_REMOTE_USER' => 'foobar' }
    }

    it 'Verify uid' do
      expect(last_request.env['omniauth.auth']['uid']).to eq('foobar')
    end

    it 'Verify info' do
      expect(last_request.env['omniauth.auth']['info']).to eq({})
    end
  end

  context 'With HTTP_REMOTE_USER and ' do
    before(:each){
      set_cookie "_remote_user=foobar"
      get "auth/RemoteUser", {}, { 'HTTP_REMOTE_USER' => 'foobar' }
    }

    it 'redirect for callback' do
      expect(last_response.status).to eq(302)
      expect(last_response.location).to eq("/auth/RemoteUser/callback")
    end
  end

end
