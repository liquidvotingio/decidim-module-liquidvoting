# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class Permissions < Decidim::DefaultPermissions
      def permissions
        return permission_action unless user.admin?
        return permission_action unless permission_action.scope == :admin
        return permission_action unless [:delegation, :setting].include?(permission_action.subject)

        allow! if can_perform_action?(permission_action.action, resource)

        permission_action
      end

      private

      def can_perform_action?(action, resource)
        if action == :destroy
          resource.present?
        else
          true
        end
      end

      def resource
        @resource ||= context.fetch(:resource, nil)
      end
    end
  end
end
