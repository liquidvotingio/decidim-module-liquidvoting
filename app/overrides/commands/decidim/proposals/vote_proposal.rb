# frozen_string_literal: true

module Decidim
  module Proposals
    # A command with all the business logic when a user votes a proposal.
    class VoteProposal < Rectify::Command
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
      # - :ok when everything is valid, together with the proposal vote.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if @proposal.maximum_votes_reached? && !@proposal.can_accumulate_supports_beyond_threshold

        build_proposal_vote
        return broadcast(:invalid) unless vote.valid?

        # ActiveRecord::Base.transaction do
        #   @proposal.with_lock do
        #     vote.save!
        #     update_temporary_votes
        #   end
        # end

        Decidim::Liquidvoting::Client.create_vote(
          # NOTE: This is a clunky way of creating the url. Probably can find a better way to pass the url here.
          # Also, what is the '.../f/...' part of the url?
          proposal_url: "http://localhost/processes/#{process.slug}/f/#{component.id}/proposals/#{proposal.id}",
          participant_email: current_user.email,
          yes: true
        )

        # NOTE: These were used by our non-ajax first attempt at a separate vote_button partial
        # session[:voted] = true
        # session[:delegated_to] = nil

        #Decidim::Gamification.increment_score(@current_user, :proposal_votes)

        broadcast(:ok, vote)
      end

      attr_reader :vote

      private

      def component
        @component ||= @proposal.component
      end

      # Used in creation of proposal url (for use by LV) which includes process title
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
        return unless minimum_votes_per_user? && user_votes.count >= minimum_votes_per_user

        user_votes.each { |vote| vote.update(temporary: false) }
      end

      def user_votes
        @user_votes ||= ProposalVote.where(
          author: @current_user,
          proposal: Proposal.where(component: component)
        )
      end

      def build_proposal_vote
        @vote = @proposal.votes.build(
          author: @current_user,
          temporary: minimum_votes_per_user?
        )
      end
    end
  end
end
