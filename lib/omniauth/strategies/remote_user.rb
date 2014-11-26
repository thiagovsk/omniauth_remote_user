module OmniAuth
  module Strategies
    class RemoteUser

      include OmniAuth::Strategy

      #option :cookie, 'rack.session'
      option :cookie, '_gitlab_session'
      option :internal_cookie, '_remote_user'


	def __write_file message 
		file = File.open("/home/git/gitlab/log/remote_user.log",'a')
		file.write " \n #{message} \n"
		file.close
	end


      def call(env)
	__write_file "Call \n"

        remote_user = env['HTTP_REMOTE_USER']

	__write_file " ... Aqui esta o remote user #{remote_user}\n"


        session_user = __current_user(env)
	__write_file " .....Aqui esta o session user ==   #{session_user}\n"

	if  ! is_in_logout? (env)
		if remote_user
		  if session_user
		    if  remote_user == session_user 
			__write_file "Entrei no remote_user == session_user"
		       super(env)
		    else
			__write_file "Entrei no remote_uer != session user com session user "      
			__logout(env) 
		    end
		
		   else
			__write_file "Estou sem session+_user= #{session_user}" 
			__login(env, remote_user) 
		  end
	       
		else
		
		   if session_user
			__write_file "Estou sem remote user e com session user  = #{session_user}" 
			__logout(env) 
		  else
			__write_file "Estou sem remote user e sem session user  = #{session_user}" 
			super(env)
		  end
		end
	else
		super env
	end
	

      end


      def is_in_logout? (env)
        request = Rack::Request.new(env)
	__write_file  "REQUEST PATH = #{request.path}"
        request.path == '/users/sign_out'	
      end

      def __current_user(env)
	__write_file "__CURRENT_USER"
        request = Rack::Request.new(env)
	__write_file  "REQUEST PATH = #{request.path}"
        request.cookies.has_key?(options.internal_cookie) && request.cookies[options.internal_cookie]
      end

      def __logout(env)
	__write_file "__LOGOUT"
        request = Rack::Request.new(env)
        response = redirect_if_not_logging_in(request, request.path)
        if response
          response.delete_cookie(options.cookie)
          response.delete_cookie(options.internal_cookie)
          response.redirect "/users/sign_out"
          response
        end
      end

       def __login(env, uid)
	__write_file "__LOGIN"
        request = Rack::Request.new(env)
        response = redirect_if_not_logging_in(request, '/users/auth/RemoteUser')
        if response
          response.set_cookie(options.internal_cookie, uid)
          response
        end
      end

      def redirect_if_not_logging_in(request, url)
	
        if ! [
          '/users/auth/RemoteUser',
          '/users/auth/RemoteUser/callback'
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
	__write_file "#{user_data} \n"
        if user_data
          data = JSON.parse(user_data)
          data['nickname'] = data['name']
          data
        else
          {}
        end
      end

      def request_phase
	__write_file "request phase\n"
	redirect "/users/auth/RemoteUser/callback"
      end
    end
  end
end

