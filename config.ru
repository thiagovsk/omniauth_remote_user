require 'sinatra'
require 'omniauth'
require 'json'

module OmniAuth
  module Strategies
    class RemoteUser

      include OmniAuth::Strategy

      option :cookie, 'rack.session'
      option :internal_cookie, '_remote_user'

      def call(env)
        remote_user = env['HTTP_REMOTE_USER']
        $stderr.puts('Remote-User: %s' % (remote_user || '(none'))
        session_user = __current_user(env)
        if remote_user
          if session_user
            if remote_user == session_user
              super(env)
            else
              __login(env, remote_user) || super(env)
            end
          else
            __login(env, remote_user) || super(env)
          end
        else
          if session_user
            __logout(env) || super(env)
          else
            super(env)
          end
        end
      end

      def __current_user(env)
        request = Rack::Request.new(env)
        request.cookies.has_key?(options.internal_cookie) && request.cookies[options.internal_cookie]
      end

      def __logout(env)
        $stderr.puts 'LOGOUT'
        request = Rack::Request.new(env)
        response = redirect_if_not_logging_in(request, request.path)
        if response
          response.delete_cookie(options.cookie)
          response.delete_cookie(options.internal_cookie)
          response
        end
      end

      def __login(env, uid)
        $stderr.puts 'LOGIN (%s)' % uid
        request = Rack::Request.new(env)
        response = redirect_if_not_logging_in(request, '/auth/remoteuser')
        if response
          response.set_cookie(options.internal_cookie, uid)
          response
        end
      end

      def redirect_if_not_logging_in(request, url)
        if ! [
          '/auth/remoteuser',
          '/auth/remoteuser/callback'
        ].include?(request.path_info)
          response = Rack::Response.new
          response.redirect url
          response
        end
      end

      uid do
        request.env['HTTP_REMOTE_USER']
      end

      info do
        user_data = request.env['HTTP_REMOTE_USER_DATA']
        if user_data
          data = JSON.parse(user_data)
          data['nickname'] = data['name']
          data
        else
          {}
        end
      end

      def request_phase
        form = OmniAuth::Form.new(:url => callback_path)
        form.html '<script type="text/javascript"> document.forms[0].submit(); </script>'
        form.to_response
      end
    end
  end
end

class MyApplication < Sinatra::Base
  use Rack::Session::Cookie, secret: '123'

  STRATEGY = 'remoteuser'
  use OmniAuth::Strategies::RemoteUser
  #STRATEGY = 'developer'
  #use OmniAuth::Strategies::Developer

  get '/login' do
    redirect '/auth/%s' % STRATEGY
  end

  get '/logout' do
    session[:current_user] = nil
    redirect '/'
  end

  post '/auth/:provider/callback' do
    session[:current_user] = request.env['omniauth.auth']['uid']
    session[:current_user_email] = request.env['omniauth.auth']['info']['email']
    session[:current_user_nickname] = request.env['omniauth.auth']['info']['nickname']
    
    redirect '/'
  end

  get '/' do
    user = session[:current_user]
    if user
      info = "(%s → %s)" % [session[:current_user_email], session[:current_user_nickname]]
      user + info + ' <a href="/logout">logout</a>'
    else
      'NOT AUTHENTICATED  <a href="/login">login</a>'
    end
  end
end

run MyApplication

