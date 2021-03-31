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
      # - :ok when everything is valid, together with the proposal.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        response = Decidim::Liquidvoting::Client.delete_vote(
          proposal_url: ResourceLocatorPresenter.new(@proposal).url,
          participant_email: current_user.email
        )

        new_vote_count = response.voting_result&.in_favor
        Liquidvoting.update_votes_count(@proposal, new_vote_count)

        broadcast(:ok, @proposal)
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
