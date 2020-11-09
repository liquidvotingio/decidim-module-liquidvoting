# frozen_string_literal: true

module Decidim
  module Liquidvoting
    class VotesController < Decidim::Liquidvoting::ApplicationController
      before_action :authenticate_user!

      def create
        Decidim::Liquidvoting::Client.create_vote(
          proposal_url: params[:proposal_url],
          participant_email: params[:participant_email],
          yes: true,
        )

        session[:voted] = true
        flash[:notice] = "You have voted 'in favor' of this proposal"
      rescue Exception => e
        flash[:error] = e.message
      ensure
        redirect_to request.referer
      end

      def current_component
        Decidim::Component.where(manifest_name: "liquidvoting").first
      end

      def permission_class_chain
        [
          Decidim::Liquidvoting::Permissions
        ]
      end
    end
  end
end