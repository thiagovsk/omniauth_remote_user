require 'omniauth'

module Omniauth
  module Stratagies
    autoload :RemoteUser, 'omniauth/stratagies/remote_user'
  end

  module Remote_user
    autoload :Model, 'omniauth/remote_user/model'
    module Models
      autoload :ActiveRecord, 'omniauth/remote_user/models/active_record'
  end
end

