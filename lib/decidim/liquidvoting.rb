# frozen_string_literal: true

require "decidim/liquidvoting/admin"
require "decidim/liquidvoting/admin_engine"
require "decidim/liquidvoting/engine"
require "decidim/liquidvoting/client"
require "decidim/liquidvoting/logger"

module Decidim
  # This namespace holds the logic of the `Liquidvoting` module
  module Liquidvoting
    # rubocop:disable Rails/SkipsModelValidations
    def self.update_vote_count(proposal, new_count)
      proposal.update_columns(proposal_votes_count: new_count)
      # msg = "TRACE: Liquidvoting.update_votes_count set #{new_count.inspect} for proposal id=#{proposal.id}"
      # Decidim::Liquidvoting::Logger.info msg
    end
    # rubocop:enable Rails/SkipsModelValidations
  end
end

# User space engine, generally used in the context of proposal voting to let users
# manage their delegations
Decidim.register_global_engine(
  :liquidvoting, # this is the name of the global method to access engine routes
  Decidim::Liquidvoting::Engine,
  at: "/"
)
