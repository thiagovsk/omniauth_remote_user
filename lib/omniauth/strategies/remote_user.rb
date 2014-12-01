module OmniAuth
  module Strategies
    class RemoteUser

      include OmniAuth::Strategy

      #option :cookie, 'rack.session'
      option :cookie, '_gitlab_session'
      option :internal_cookie, '_remote_user'

      def call(env)
        remote_user = env['HTTP_REMOTE_USER']
        session_user = __current_user(env)

        if  ! is_in_logout? (env)
          if remote_user
            if session_user
              if remote_user == session_user
                super(env)
              else
                __logout(env) || super(env)
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
        else
          super env
        end
      end

      def __current_user(env)
        request = Rack::Request.new(env)
        request.cookies.has_key?(options.internal_cookie) && request.cookies[options.internal_cookie]
      end

      def __logout(env)
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
        request = Rack::Request.new(env)
        response = redirect_if_not_logging_in(request, "#{OmniAuth.config.path_prefix}/#{name}/callback")
        if response
          response.set_cookie(options.internal_cookie, uid)
          response
        end
      end

      def is_in_logout? (env)
        request = Rack::Request.new(env)
        request.path == '/users/sign_out'
      end

      def redirect_if_not_logging_in(request, url)
        if ! [
            "#{OmniAuth.config.path_prefix}/#{name}/",
            "#{OmniAuth.config.path_prefix}/#{name}/callback"
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
        "#{OmniAuth.config.path_prefix}/#{name}/callback"
      end
    end
  end
end
