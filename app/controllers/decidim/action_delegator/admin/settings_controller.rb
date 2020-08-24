# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Admin
      class SettingsController < ActionDelegator::Admin::ApplicationController
        layout "decidim/action_delegator/admin/settings"

        def new
          @setting = Setting.new
        end

        def create
          @setting = build_setting

          if @setting.save
            flash[:notice] = I18n.t("settings.create.success", scope: "decidim.action_delegator.admin")
            redirect_to decidim_admin_action_delegator.delegations_path
          else
            flash[:error] = I18n.t("settings.create.error", scope: "decidim.action_delegator.admin")
          end
        end

        private

        def setting_params
          params.require(:setting).permit(:max_grants, :expires_at)
        end

        def build_setting
          setting = Setting.new(setting_params)
          setting.organization = current_organization
          setting
        end
      end
    end
  end
end
