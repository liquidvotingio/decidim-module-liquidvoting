# frozen_string_literal: true

module Decidim
  module Liquidvoting
    class DelegationsController < Decidim::Liquidvoting::ApplicationController
      before_action :authenticate_user!

      def create
        # TODO: enforce_permission_to :delegate, :proposal, proposal: proposal

        Decidim::Liquidvoting::Client.create_delegation(
          proposal_url: params[:proposal_url],
          delegator_email: current_user&.email,
          delegate_email: params[:delegate_email]
        )

        @lv_state = Decidim::Liquidvoting::Client.current_proposal_state(current_user&.email, params[:proposal_url])
        flash[:notice] = "Delegated support to #{Decidim::User.find_by(email: @lv_state.delegate_email).name}."

      rescue StandardError => e
        flash[:error] = e.message
      ensure
        redirect_to request.referer
      end

      def index
        respond_to do |format|
          format.html { render html: "<p>placeholder module homepage</p>".html_safe }
        end
      end

      def destroy
        # TODO: enforce_permission_to :undelegate, :proposal, proposal: proposal

        Decidim::Liquidvoting::Client.delete_delegation(
          proposal_url: params[:proposal_url],
          delegator_email: current_user&.email,
          delegate_email: params[:delegate_email]
        )

        @lv_state = Decidim::Liquidvoting::Client.current_proposal_state(current_user&.email, params[:proposal_url])
        flash[:notice] = "Removed delegation to #{Decidim::User.find_by(email: params[:delegate_email]).name}."

      rescue StandardError => e
        flash[:error] = e.message
      ensure
        redirect_to request.referer
      end

      def current_component
        Decidim::Component.find_by(manifest_name: "liquidvoting")
      end

      def permission_class_chain
        [
          Decidim::Liquidvoting::Permissions
        ]
      end
    end
  end
end
