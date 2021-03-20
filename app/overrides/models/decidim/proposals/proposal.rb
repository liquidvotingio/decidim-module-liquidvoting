# frozen_string_literal: true

Decidim::Proposals::Proposal.class_eval do
  # We override this method so we can explicitly pass the Liquidvoting vote count.
  # The original Decidim::Proposals::Proposal uses a :counter_cache to sum the
  # ProposalVote model, which we've abandoned.
  #
  # The :proposal_votes_count attribute is now completely managed by Liquidvoting, in this method.
  # rubocop:disable Rails/SkipsModelValidations
  def update_votes_count(lv_count = nil)
    return unless lv_count

    Decidim::Liquidvoting::Logger.info "TRACE: Surprise, who called Proposal#update_votes_count? Liquidvoting uses :set_votes_count"
    update_columns(proposal_votes_count: lv_count)
  end
  # rubocop:enable Rails/SkipsModelValidations
end
