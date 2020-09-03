# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Admin
      class SettingsController < ActionDelegator::Admin::ApplicationController
        helper DelegationHelper
        include Filterable

        layout "decidim/admin/users"

        def index
          enforce_permission_to :index, :setting

          @settings = filtered_collection.map do |setting|
            SettingPresenter.new(setting)
          end
        end

        def new
          enforce_permission_to :create, :setting

          @setting = Setting.new(max_grants: 1)
        end

        def create
          enforce_permission_to :create, :setting

          @setting = build_setting

          if @setting.save
            flash[:notice] = I18n.t("settings.create.success", scope: "decidim.action_delegator.admin")
            redirect_to decidim_admin_action_delegator.settings_path
          else
            flash[:error] = I18n.t("settings.create.error", scope: "decidim.action_delegator.admin")
          end
        end

        def destroy
          enforce_permission_to :destroy, :setting, resource: setting

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
          @setting ||= collection.find_by(id: params[:id])
        end

        def collection
          @collection ||= OrganizationSettings.new(current_organization).query
        end
      end
    end
  end
end
