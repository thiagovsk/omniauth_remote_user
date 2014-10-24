module OmniAuth
  module Stratagies
    class RemoteUser
      include OmniAuth::Strategy

      option :fields, [:name, :email]
      option :uid_field, :name

      def request_phase

      end

      def callback_phase

      end
    end
  end
end
