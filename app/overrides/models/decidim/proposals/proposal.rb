# frozen_string_literal: true

# Liquidvoting repurposes the :proposal_votes_count attribute to carry the current vote
# count from the Liquidvoting external service.
#
# To repurpose, we override the existing :update_votes_count method to no longer refresh the count
# from the :votes association, and to log the (unexpected) event. This can happen when other Decidim
# code, for example seeding the database, calls the method. The :votes association and ProposalVote
# model are considered abandoned.
#
# We also add an explicit :set_votes_count method that will set the attribute with the current
# Liquidvoting count, and also log the event. This is the expected way to manage the attribute.
#
Decidim::Proposals::Proposal.class_eval do
  def update_votes_count
    Decidim::Liquidvoting::Logger.info "TRACE: Surprise :update_votes_count call; Liquidvoting uses :set_votes_count"
  end

  # rubocop:disable Naming/AccessorMethodName
  # rubocop:disable Rails/SkipsModelValidations
  def set_votes_count(lv_count)
    update_columns(proposal_votes_count: lv_count)
    Decidim::Liquidvoting::Logger.info "TRACE: Liquidvoting set the proposal_votes_count to #{lv_count.inspect}"
  end
  # rubocop:enable Naming/AccessorMethodName
  # rubocop:enable Rails/SkipsModelValidations
end
