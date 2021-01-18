# frozen_string_literal: true

Decidim::Proposals::Proposal.class_eval do
  def user_has_voted?(email, url)
    Decidim::Liquidvoting::Client.vote_for(email, url).nil? ? false : true
  end
end
