module OmniAuth
  module Stratagies
    class RemoteUser
      include OmniAuth::Strategy

      def validate_remote_user
        if !env['HTTP_REMOTE_USER'].blank?
          env['HTTP_REMOTE_USER']
        else
          env['HTTP_X_FORWARDED_USER']
        end
      end

      def request_phase
        @uid = validate_remote_user
        return fail!(:no_remote_user) unless @uid

        @user_data[:name] = @uid['NAME']
        @user_data[:email] = @uid['EMAIL']

        @env['omniauth.auth'] = auth_hash
        @env['REQUEST_METHOD'] = 'GET'
        @env['PATH_INFO'] = "#{OmniAuth.config.path_prefix}/#{name}/callback"

        call_app!
      end

      uid { @uid['EMAIL'] }
      info{ @user_data }
    
    end
  end
end
