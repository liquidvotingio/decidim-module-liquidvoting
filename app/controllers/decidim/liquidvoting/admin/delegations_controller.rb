# frozen_string_literal: true

module Decidim
  module Liquidvoting
    module Admin
      class DelegationsController < Liquidvoting::Admin::ApplicationController
        include NeedsPermission
        include Filterable

        helper DelegationHelper
        helper_method :current_setting

        layout "decidim/liquidvoting/admin/delegations"

        def index
          enforce_permission_to :index, :delegation

          @delegations = filtered_collection.map do |delegation|
            DelegationPresenter.new(delegation)
          end
        end

        def new
          enforce_permission_to :create, :delegation

          @delegation = Delegation.new
        end

        def create
          enforce_permission_to :create, :delegation

          @delegation = build_delegation

          if @delegation.save
            notice = I18n.t("delegations.create.success", scope: "decidim.liquidvoting.admin")
            redirect_to setting_delegations_path(@delegation.setting), notice: notice
          else
            flash.now[:error] = I18n.t("delegations.create.error", scope: "decidim.liquidvoting.admin")
          end
        end

        def destroy
          enforce_permission_to :destroy, :delegation, resource: delegation

          setting_id = delegation.setting.id

          if delegation.destroy
            notice = I18n.t("delegations.destroy.success", scope: "decidim.liquidvoting.admin")
            redirect_to setting_delegations_path(setting_id), notice: notice
          else
            error = I18n.t("delegations.destroy.error", scope: "decidim.liquidvoting.admin")
            redirect_to setting_delegations_path(setting_id), flash: { error: error }
          end
        end

        private

        def build_delegation
          attributes = delegation_params.merge(setting: current_setting)
          Delegation.new(attributes)
        end

        def delegation_params
          params.require(:delegation).permit(:granter_id, :grantee_id)
        end

        def delegation
          @delegation ||= collection.find_by(id: params[:id])
        end

        def collection
          @collection ||= SettingDelegations.new(current_setting).query
        end

        def current_setting
          @current_setting ||= organization_settings.find_by(id: params[:setting_id])
        end

        def organization_settings
          OrganizationSettings.new(current_organization).query
        end
      end
    end
  end
end
