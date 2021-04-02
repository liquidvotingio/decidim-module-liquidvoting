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
        super()
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
        return broadcast(:invalid) if @proposal.maximum_votes_reached? &&
                                      !@proposal.can_accumulate_supports_beyond_threshold

        # We build only to validate; we don't save votes in Decidim, we abandoned the ProposalVote model
        build_proposal_vote
        return broadcast(:invalid) unless vote.valid?

        response = Decidim::Liquidvoting::ApiClient.create_vote(
          proposal_url: ResourceLocatorPresenter.new(@proposal).url,
          participant_email: current_user.email,
          yes: true
        )

        new_vote_count = response.voting_result&.in_favor
        Liquidvoting.update_votes_count(@proposal, new_vote_count)

        broadcast(:ok, vote)
      end

      attr_reader :vote

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
        return unless minimum_votes_per_user? && user_votes.count >= minimum_votes_per_user

        user_votes.each { |vote| vote.update(temporary: false) }
      end

      def user_votes
        Rails.logger.info "TRACE: VoteProposal#user_votes, who called this, Liquidvoting is managing user votes!"
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
