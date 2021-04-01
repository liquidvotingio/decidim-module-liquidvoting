# frozen_string_literal: true

require "decidim/liquidvoting/admin"
require "decidim/liquidvoting/admin_engine"
require "decidim/liquidvoting/engine"
require "decidim/liquidvoting/api_client"
require "decidim/liquidvoting/logger"

module Decidim
  # This namespace holds the logic of the `Liquidvoting` module
  module Liquidvoting
    # rubocop:disable Rails/SkipsModelValidations
    def self.update_votes_count(proposal, new_count)
      proposal.update_columns(proposal_votes_count: new_count)

      msg = "TRACE: Liquidvoting.update_votes_count set #{new_count.inspect} for proposal id=#{proposal.id}"
      Decidim::Liquidvoting::Logger.info msg
    end
    # rubocop:enable Rails/SkipsModelValidations

    UserProposalState = Struct.new(:user_has_supported, :delegate_email)

    def self.user_proposal_state(user_email, proposal_url)
      user_has_supported = Decidim::Liquidvoting::ApiClient.fetch_user_supported(user_email, proposal_url)

      UserProposalState.new(user_has_supported, nil)
    end
  end
end

# User space engine, generally used in the context of proposal voting to let users
# manage their delegations
Decidim.register_global_engine(
  :liquidvoting, # this is the name of the global method to access engine routes
  Decidim::Liquidvoting::Engine,
  at: "/"
)
