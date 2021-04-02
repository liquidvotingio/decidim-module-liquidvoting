# frozen_string_literal: true

# Liquidvoting repurposes the :proposal_votes_count attribute in this model to carry instead
# the current vote count from the Liquidvoting external service, and not a cached
# count from the Proposal#votes association.

# Because we are bypassing the Proposal#votes association and ProposalVote model, we don't
# really expect this :update_votes_count method to be called. However, it can happen, as in
# the rake db:seeds. So we've overridden the method to log the occurrence.
#
# See the Decidim::Liquidvoting.update_votes_count for the canonical way to update vote counts.
#
Decidim::Proposals::Proposal.class_eval do
  # rubocop:disable Rails/SkipsModelValidations
  def update_votes_count
    msg = "TRACE: Surprise :update_votes_count call; see Decidim::Liquidvoting.update_votes_count"
    Decidim::Liquidvoting::Logger.info msg

    update_columns(proposal_votes_count: votes.count) # IDK why `super` doesn't work here
  end
  # rubocop:enable Rails/SkipsModelValidations
end
