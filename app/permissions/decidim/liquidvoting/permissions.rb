# frozen_string_literal: true

module Decidim
  module Liquidvoting
    class Permissions < Decidim::DefaultPermissions
      # def permissions
      #   return permission_action unless user.admin?
      #   return permission_action unless permission_action.scope == :admin

      #   allow! if can_perform_action?(permission_action.action, resource)

      #   permission_action
      # end

      def permissions
        allow!

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
