# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Admin
      class SettingsController < ActionDelegator::Admin::ApplicationController
        helper DelegationHelper

        layout "decidim/action_delegator/admin/settings"

        def index
          @settings = Setting.all.map do |setting|
            SettingPresenter.new(setting)
          end
        end

        def new
          @setting = Setting.new
        end

        def create
          @setting = build_setting

          if @setting.save
            flash[:notice] = I18n.t("settings.create.success", scope: "decidim.action_delegator.admin")
            redirect_to decidim_admin_action_delegator.settings_path
          else
            flash[:error] = I18n.t("settings.create.error", scope: "decidim.action_delegator.admin")
          end
        end

        def destroy
          if setting.destroy
            flash[:notice] = I18n.t("settings.destroy.success", scope: "decidim.action_delegator.admin")
          else
            flash[:error] = I18n.t("settings.destroy.error", scope: "decidim.action_delegator.admin")
          end

          redirect_to settings_path
        end

        private

        def setting_params
          params.require(:setting).permit(:max_grants, :expires_at, :decidim_consultation_id)
        end

        def build_setting
          Setting.new(setting_params)
        end

        def setting
          Setting.find_by(id: params[:id])
        end
      end
    end
  end
end
