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

        # TODO: how do we step up to proposal lists?
        @from_proposals_list = params[:from_proposals_list] == "true"
        @proposals = [] + [proposal]

        @lv_state = Decidim::Liquidvoting::Client.current_proposal_state(current_user&.email, params[:proposal_url])
        render "decidim/proposals/proposal_votes/update_buttons_and_counters"

        # flash[:notice] = "Delegated support to #{Decidim::User.find_by(email: @lv_state.delegate_email).name}."
      # rescue StandardError => e
      #   flash[:error] = e.message
      # ensure
      #   redirect_to request.referer
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

        # TODO: how do we step up to proposal lists?
        @from_proposals_list = params[:from_proposals_list] == "true"
        @proposals = [] + [proposal]

        @lv_state = Decidim::Liquidvoting::Client.current_proposal_state(current_user&.email, params[:proposal_url])
        render "decidim/proposals/proposal_votes/update_buttons_and_counters"
        # flash[:notice] = "Removed delegation to #{Decidim::User.find_by(email: params[:delegate_email]).name}."
      # rescue StandardError => e
      #   flash[:error] = e.message
      # ensure
      #   redirect_to request.referer
      end

      # TODO is this used? how is it used? elsewhere we use "proposals" component for db filtering for example
      def current_component
        Decidim::Component.find_by(manifest_name: "liquidvoting")
      end

      def permission_class_chain
        [
          Decidim::Liquidvoting::Permissions
        ]
      end

      private

      def proposal
        # TODO: not filtering on current_component because confused about "proposals" vs "liquidvoting"
        # @proposal ||= Decidim::Proposals::Proposal.where(component: current_component).find(params[:proposal_id])
        # TODO: why do we have to qualify Proposal? is it "isolate_namespace Decidim::Liquidvoting" in engine.rb?
        @proposal ||= Decidim::Proposals::Proposal.find(params[:proposal_id])
      end

      def lv_state
        # don't conditionally assign, always get a fresh one
        @lv_state = Decidim::Liquidvoting::Client.current_proposal_state(
          current_user&.email,
          ResourceLocatorPresenter.new(proposal).url
        )
      end

    end
  end
end
