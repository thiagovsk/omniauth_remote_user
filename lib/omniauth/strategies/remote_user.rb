module OmniAuth
  module Stratagies
    class RemoteUser
      include OmniAuth::Strategy

      def call(env)
        request = Rack::Request.new env
        cookies = request.cookies
        response = Rack::Response.new

        if cookies['gitlab_session'] != nil and !env['HTTP_REMOTE_USER'].blank?
          response.redirect "#{OmniAuth.config.path_prefix}/users/auth/env/"
        else
          super(env)
        end

      end

      def request_phase
        @user_data = {}
        @uid = env
        return fail!(:no_remote_user) unless @uid

        @user_data[:name] = @uid['NAME']
        @user_data[:email] = @uid['EMAIL']

        @env['omniauth.auth'] = auth_hash
        @env['REQUEST_METHOD'] = 'GET'
        @env['PATH_INFO'] = "#{OmniAuth.config.path_prefix}/#{name}/callback"

        call_app!
      end

      uid { @uid['NAME'] }
      info{ @user_data }

      def callback_phase
        fail(:invalid_request)
      end

      def auth_hash
        Omniauth::Utils.deep_merge(super, {'uid' => @uid})
      end
    end
  end
end
