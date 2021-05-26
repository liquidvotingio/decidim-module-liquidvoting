# frozen_string_literal: true

Decidim::Proposals::VoteProposal.class_eval do
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
  # - :invalid if the form wasn't valid and we couldn't proceed.
  #
  # Returns nothing.
  def call
    return broadcast(:invalid) if @proposal.maximum_votes_reached? &&
                                  !@proposal.can_accumulate_supports_beyond_threshold

    # We build only to validate; we don't save votes in Decidim, we abandoned the ProposalVote model
    build_proposal_vote
    return broadcast(:invalid) unless vote.valid?

    Decidim::Liquidvoting.create_vote(current_user.email, @proposal)

    broadcast(:ok)
  end

  private

  def user_votes
    Rails.logger.info "TRACE: VoteProposal#user_votes, who called this, Liquidvoting is managing user votes!"
    @user_votes ||= Decidim::Proposals::ProposalVote.where(
      author: @current_user,
      proposal: Decidim::Proposals::Proposal.where(component: component)
    )
  end
end
