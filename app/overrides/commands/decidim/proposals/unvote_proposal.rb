# frozen_string_literal: true

Decidim::Proposals::UnvoteProposal.class_eval do
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
    Decidim::Liquidvoting.delete_vote(current_user.email, @proposal)

    broadcast(:ok)
  end

  private

  def user_votes
    Rails.logger.info "TRACE: UnvoteProposal#user_votes, who called this, Liquidvoting is managing user votes!"
    @user_votes ||= Decidim::Proposals::ProposalVote.where(
      author: @current_user,
      proposal: Decidim::Proposals::Proposal.where(component: component)
    )
  end
end
