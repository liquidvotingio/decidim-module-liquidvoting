# frozen_string_literal: true

module Decidim
  module Liquidvoting
    class DelegationsController < Decidim::Proposals::ApplicationController
      before_action :authenticate_user!
      before_action :set_proposal
      helper_method :proposal_path
      helper_method :proposal_proposal_vote_path

      def create
        # TODO: enforce_permission_to :delegate, :proposal, proposal: proposal
        # enforce_permission_to :vote, :proposal, proposal: proposal

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
        # enforce_permission_to :unvote, :proposal, proposal: proposal

        Decidim::Liquidvoting::Client.delete_delegation(
          proposal_url: params[:proposal_url],
          delegator_email: current_user&.email,
          delegate_email: params[:delegate_email]
        )

        # TODO: how do we step up to proposal lists? maybe remove, make people vote from proposal page itself
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

      def lv_state
        # don't conditionally assign, always get a fresh one
        @lv_state = Decidim::Liquidvoting::Client.current_proposal_state(
          current_user&.email,
          proposal_locator_presenter.url
        )
      end

      def current_component
        proposal.component
        # proposal_locator_presenter.component
      end

      def current_participatory_space
        current_component.participatory_space
      end

      private

      def proposal_locator_presenter
        ResourceLocatorPresenter.new(@proposal)
      end

      def proposal_path(_proposal)
        proposal_locator_presenter.path
      end

      def proposal_proposal_vote_path(_ignore)
        "#{proposal_path(nil)}/proposal_vote"
      end

      def proposal
        # TODO: why do we have to qualify Proposal? something to do with "isolate_namespace Decidim::Liquidvoting" in engine.rb?
        # This is a cheat; :set_proposal isn't firing early enough for general Decidim work
        @proposal ||= Decidim::Proposals::Proposal.find(params[:proposal_id])
      end

      def set_proposal
        @proposal = Decidim::Proposals::Proposal.published.not_hidden.where(component: current_component).find_by(id: params[:id])
      end

    end
  end
end
