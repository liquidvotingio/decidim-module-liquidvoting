# frozen_string_literal: true

module Decidim
  module Proposals
    # A command with all the business logic when a user unvotes a proposal.
    class UnvoteProposal < Rectify::Command
      # Public: Initializes the command.
      #
      # proposal     - A Decidim::Proposals::Proposal object.
      # current_user - The current user.
      def initialize(proposal, current_user)
        super()
        @proposal = proposal
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid
      #
      # Returns nothing.
      def call
        Liquidvoting.delete_vote(current_user.email, @proposal)

        broadcast(:ok)
      end

      private

      def component
        @component ||= @proposal.component
      end

      def minimum_votes_per_user
        component.settings.minimum_votes_per_user
      end

      def minimum_votes_per_user?
        minimum_votes_per_user.positive?
      end

      def update_temporary_votes
        return unless minimum_votes_per_user? && user_votes.count < minimum_votes_per_user

        user_votes.each { |vote| vote.update(temporary: true) }
      end

      def user_votes
        Rails.logger.info "TRACE: UnvoteProposal#user_votes, who called this, Liquidvoting is managing user votes!"
        @user_votes ||= ProposalVote.where(
          author: @current_user,
          proposal: Proposal.where(component: component)
        )
      end
    end
  end
end
