# frozen_string_literal: true

require "decidim/action_delegator/admin"
require "decidim/action_delegator/admin_engine"
require "decidim/action_delegator/engine"
require "decidim/action_delegator/verification/admin"
require "decidim/action_delegator/verification/admin_engine"
require "decidim/action_delegator/verification/engine"
require "decidim/action_delegator/workflow"

module Decidim
  # This namespace holds the logic of the `Liquidvoting` module
  module Liquidvoting
  end
end

# We register 2 global engines to handle logic unrelated to participatory spaces or components

# User space engine, used mostly in the context of the user profile to let the users
# manage their delegations
Decidim.register_global_engine(
  :decidim_action_delegator, # this is the name of the global method to access engine routes
  ::Decidim::Liquidvoting::Engine,
  at: "/action_delegator"
)

# Admin side of the delegations management. Admins can overlook all delegations and
# create their own
Decidim.register_global_engine(
  :decidim_admin_action_delegator,
  ::Decidim::Liquidvoting::AdminEngine,
  at: "/admin/action_delegator"
)
