# frozen_string_literal: true

require "decidim/liquidvoting/admin"
require "decidim/liquidvoting/admin_engine"
require "decidim/liquidvoting/engine"
require "decidim/liquidvoting/verification/admin"
require "decidim/liquidvoting/verification/admin_engine"
require "decidim/liquidvoting/verification/engine"
require "decidim/liquidvoting/workflow"

module Decidim
  # This namespace holds the logic of the `Liquidvoting` module
  module Liquidvoting
  end
end

# We register 2 global engines to handle logic unrelated to participatory spaces or components

# User space engine, used mostly in the context of the user profile to let the users
# manage their delegations
Decidim.register_global_engine(
  :decidim_liquidvoting, # this is the name of the global method to access engine routes
  ::Decidim::Liquidvoting::Engine,
  at: "/liquidvoting"
)

# Admin side of the delegations management. Admins can overlook all delegations and
# create their own
Decidim.register_global_engine(
  :decidim_admin_liquidvoting,
  ::Decidim::Liquidvoting::AdminEngine,
  at: "/admin/liquidvoting"
)
