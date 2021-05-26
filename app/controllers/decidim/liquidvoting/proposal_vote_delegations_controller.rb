# frozen_string_literal: true

module Decidim
  module Liquidvoting
    class ProposalVoteDelegationsController < Decidim::Proposals::ApplicationController
      before_action :authenticate_user!

      helper_method :proposal, :proposal_path, :proposal_proposal_vote_path, :api_state

      def create
        enforce_permission_to :vote, :proposal, proposal: proposal

        Liquidvoting.create_delegation(delegator_email, delegate_email, proposal)
        refresh_from_api

        @from_proposals_list = params[:from_proposals_list] == "true"
        @proposals = [] + [proposal]

        render "decidim/proposals/proposal_votes/update_buttons_and_counters"
      end

      def index
        respond_to do |format|
          format.html { render html: "<p>placeholder module homepage</p>".html_safe }
        end
      end

      def destroy
        enforce_permission_to :unvote, :proposal, proposal: proposal

        Liquidvoting.delete_delegation(delegator_email, delegate_email, proposal)
        refresh_from_api

        @from_proposals_list = params[:from_proposals_list] == "true"
        @proposals = [] + [proposal]

        render "decidim/proposals/proposal_votes/update_buttons_and_counters"
      end

      private

      def proposal
        @proposal ||= Decidim::Proposals::Proposal.where(component: current_component).find(params[:proposal_id])
      end

      def delegator_email
        current_user&.email
      end

      def delegate_email
        User.find(params[:delegate_id])&.email
      end

      # Helpers for cross-engine routing

      def proposal_locator
        @proposal_locator ||= Decidim::ResourceLocatorPresenter.new(@proposal)
      end

      def proposal_path(_ignore)
        proposal_locator.path
      end

      def proposal_proposal_vote_path(_ignore)
        "#{proposal_path(nil)}/proposal_vote"
      end

      attr_reader :api_state

      # Retrieve the current liquidvoting state. The state is exposed as a helper method :api_state.
      # Since timing with regard to votes and delegations is important, make this a deliberate act,
      # rather than a lazy memoized attribute.
      def refresh_from_api
        @api_state = Liquidvoting.user_proposal_state(delegator_email, proposal_locator.url)
      end
    end
  end
end
