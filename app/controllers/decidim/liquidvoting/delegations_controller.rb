# frozen_string_literal: true

module Decidim
  module Liquidvoting
    # class DelegationsController < Decidim::ApplicationController
    # class DelegationsController < Decidim::Components::BaseController
    class DelegationsController < Decidim::Proposals::ApplicationController
      before_action :authenticate_user!

      def create
byebug
# proposal proposals @proposal
# request.env["decidim.current_component"]
# current_component current_settings
# model.component resource.component
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

      def proposal
        # TODO: not filtering on current_component because confused about "proposals" vs "liquidvoting"
        # @proposal ||= Decidim::Proposals::Proposal.where(component: current_component).find(params[:proposal_id])
        # TODO: why do we have to qualify Proposal? is it "isolate_namespace Decidim::Liquidvoting" in engine.rb?
        @proposal ||= Decidim::Proposals::Proposal.find(params[:proposal_id])
      end

      def current_component
        proposal.component
      end

      def current_participatory_space
        current_component.participatory_space
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
