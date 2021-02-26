# frozen_string_literal: true

module Decidim
  module Liquidvoting
    class VotesController < Decidim::Liquidvoting::ApplicationController
      before_action :authenticate_user!

      # rubocop:disable Lint/UnreachableCode
      def create
        # TODO: Remove? I think this Controller was a LV add, not an override, and we probably are not using it?
        raise "BOOM: did not expect to create a vote in VotesController; maybe you want ProposalVotesController?"
        Decidim::Liquidvoting::Client.create_vote(
          proposal_url: params[:proposal_url],
          participant_email: params[:participant_email],
          yes: true
        )

        session[:voted] = true
        session[:delegated_to] = nil
        flash[:notice] = "Vote created."
      rescue StandardError => e
        flash[:error] = e.message
      ensure
        redirect_to request.referer
      end

      def destroy
        raise "BOOM: did not expect to create a vote in VotesController; maybe you want ProposalVotesController?"
        Decidim::Liquidvoting::Client.delete_vote(
          proposal_url: params[:proposal_url],
          participant_email: params[:participant_email]
        )

        flash[:notice] =
          "Vote deleted."
        session[:voted] = false
      rescue StandardError => e
        flash[:error] = e.message
      ensure
        redirect_to request.referer
      end
      # rubocop:enable Lint/UnreachableCode

      # def current_component
      #   Decidim::Component.find_by(manifest_name: "liquidvoting")
      # end

      # def permission_class_chain
      #   [
      #     Decidim::Liquidvoting::Permissions
      #   ]
      # end
    end
  end
end
