# frozen_string_literal: true

Decidim::Proposals::Proposal.class_eval do
  # Public: Returns true if vote by user (identified by email) on a propsal
  # (identified by url) exists.
  #
  # Returns a boolean
  def user_has_voted?(email, url)
    Decidim::Liquidvoting::Client.vote_for(email, url).nil? ? false : true
  end

  # Public: Gets current vote count for proposal (identified by id).
  #
  # Returns an integer.
  def get_progress(component)
    url = "http://localhost/processes/"\
      "#{component.participatory_space.slug}/f/#{component.id}/proposals/#{id}"
    Decidim::Liquidvoting::Client.voting_result(url) || 0
  end

  # Public: Updates the vote count of this proposal.
  #
  # Returns nothing.
  #
  # rubocop:disable Rails/SkipsModelValidations
  def update_votes_count(component)
    update_columns(proposal_votes_count: get_progress(component))
  end

  # rubocop:enable Rails/SkipsModelValidations
end
