require 'sinatra'
require 'omniauth'
require 'json'

class MyApplication < Sinatra::Base
  use Rack::Session::Cookie, secret: '123'

  STRATEGY = 'RemoteUser'
  #use OmniAuth::Strategies::RemoteUser
  #STRATEGY = 'developer'
  use OmniAuth::Strategies::Developer


  get '/login' do
    redirect '/gitlab/auth/%s' % STRATEGY
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

