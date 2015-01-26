module OmniAuth
  module Strategies
    class RemoteUser
      include OmniAuth::Strategy

      option :internal_cookie, '_remote_user'

      def call(env)

        remote_user = env['HTTP_REMOTE_USER']
        session_user = __current_user(env)

        if remote_user
          if session_user
            if remote_user == session_user
              super(env)
            else
              __logout(env)
            end
          else
            __login(env, remote_user)
          end
        else
          if session_user
            __logout(env)
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
        request = Rack::Request.new(env)
        request.session.clear
        response = redirect_if_not_logging_in(request, request.path )
        if response
          response.delete_cookie(options.internal_cookie , path: "#{request.script_name}" )
          response.finish
        end
      end

      def __login(env, uid)
        request = Rack::Request.new(env)
        response = redirect_if_not_logging_in(request,_auth_path(request) )
        if response
          response.set_cookie(options.internal_cookie, {value: uid , path: "#{request.script_name}"})
          response.finish
        end
      end

      def redirect_if_not_logging_in(request, url)
        if ! [
            _auth_path(request),
            _callback_path(request)
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
          data['nickname'] = data['firstname'] = data['name'].split()[0]
          data['lastname'] = data['name'].split()[1]
          data
        else
          {}
        end
      end

      def request_phase
        redirect _callback_path(request)
      end

      def _callback_path(request)
        "#{_auth_path(request)}/callback"
      end

      def _auth_path(request)
        "#{request.script_name}#{path_prefix}/RemoteUser"
      end

    end
  end
end
