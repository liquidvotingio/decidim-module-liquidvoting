# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class Permissions < Decidim::DefaultPermissions
      def permissions
        return permission_action unless user.admin?
        return permission_action unless permission_action.scope == :admin
        return permission_action unless permission_action.subject == :delegation

        allow!
        permission_action
      end
    end
  end
end
