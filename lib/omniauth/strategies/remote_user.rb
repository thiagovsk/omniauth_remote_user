module OmniAuth
  module Strategies
    class RemoteUser
      include OmniAuth::Strategy

      option :fields, [:name, :email]
      option :uid_field, :email

      def call(env)
        request = Rack::Request.new env
        cookies = request.cookies["_gitlab_session"]
        remote_user = env["HTTP_REMOTE_USER"]
        unless remote_user.empty? && cookies.empty?
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
