# frozen_string_literal: true

Decidim::Proposals::Proposal.class_eval do
  # TODO: We should probably un-override the Proposal model from the liquidvoting module;
  #       for now, we're just logging the use of the proposal_votes_count attribute (we use LV instead for vote counts)

  def update_votes_count(component)
    Rails.logger.warn "SURPRISE: Proposal#update_votes_count: This module uses Liquidvoting to manage proposal votes count; this code path is probably obsolete"
  end

  def proposal_votes_count
    Rails.logger.warn "SURPRISE: Proposal#proposal_votes_count: This module uses Liquidvoting to manage proposal votes count; this code path is probably obsolete"
  end
end
