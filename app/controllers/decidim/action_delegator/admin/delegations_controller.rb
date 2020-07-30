# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Admin
      class DelegationsController < ActionDelegator::Admin::ApplicationController
        include NeedsPermission

        layout "decidim/admin/users"

        def index
          # some permissions
          delegations = Delegation.all
          render :index, locals: { delegations: delegations }
        end

        def destroy
          if delegation.destroy
            notice = I18n.t("delegations.destroy.success", scope: "decidim.action_delegator.admin")
            redirect_to delegations_path, notice: notice
          else
            error = I18n.t("delegations.destroy.error", scope: "decidim.action_delegator.admin")
            redirect_to delegations_path, flash: { error: error }
          end
        end

        private

        def delegation
          Delegation.find_by(id: params[:id])
        end
      end
    end
  end
end
