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
        # ActiveRecord::Base.transaction do
        #   ProposalVote.where(
        #     author: @current_user,
        #     proposal: @proposal
        #   ).destroy_all

        # update_temporary_votes

        Decidim::Liquidvoting::Client.delete_vote(
          proposal_url: "http://localhost/processes/#{process.slug}/f/#{component.id}/proposals/#{proposal.id}",
          participant_email: current_user.email
        )

        #Decidim::Gamification.decrement_score(@current_user, :proposal_votes)

        broadcast(:ok, @proposal)
      end

      private

      def component
        @component ||= @proposal.component
      end

      # Used in creation of proposal url (for use by LV) which includes process slug
      def process
        @process ||= component.participatory_space
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
        @user_votes ||= ProposalVote.where(
          author: @current_user,
          proposal: Proposal.where(component: component)
        )
      end
    end
  end
end
