# frozen_string_literal: true

Decidim::Proposals::Proposal.class_eval do
  # Public: Updates the vote count of this proposal.
  #
  # Returns nothing.
  #
  # rubocop:disable Rails/SkipsModelValidations
  def update_votes_count(component)
    # TODO: remove this :proposal_votes_count updater"
    msg = "BOOM Proposal#update_votes_count: This module uses Liquidvoting to manage proposal votes count; this code path is probably obsolete"
    Rails.logger.warn msg
    # fail msg

    update_columns(proposal_votes_count: get_progress(component))
  end

  def proposal_votes_count
    # TODO: remove this :proposal_votes_count accessor"
    msg = "BOOM Proposal#proposal_votes_count: This module uses Liquidvoting to manage proposal votes count; this code path is probably obsolete"
    Rails.logger.warn msg
    # fail msg

    super
  end

  # rubocop:enable Rails/SkipsModelValidations
end
