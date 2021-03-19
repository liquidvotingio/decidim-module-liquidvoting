# frozen_string_literal: true

Decidim::Proposals::Proposal.class_eval do
  # We override this method so we can explicitly pass the Liquidvoting vote count.
  # The original Decidim::Proposals::Proposal uses a :counter_cache to sum the
  # ProposalVote model, which we've abandoned.
  #
  # The :proposal_votes_count attribute is now completely managed by Liquidvoting, in this method.

  # If some legacy code still calls this without an argument (eg rake db:seed), return w/o action
  #
  # rubocop:disable Rails/SkipsModelValidations
  def update_votes_count(lv_count = nil)
    return unless lv_count

    Rails.logger.info "TRACE: Proposal#update_votes_count updating with #{lv_count.inspect}"
    update_columns(proposal_votes_count: lv_count)
  end
  # rubocop:enable Rails/SkipsModelValidations
end
