# frozen_string_literal: true

require "decidim/liquidvoting/admin"
require "decidim/liquidvoting/admin_engine"
require "decidim/liquidvoting/engine"

module Decidim
  # This namespace holds the logic of the `Liquidvoting` module
  module Liquidvoting
  end
end


# User space engine, used mostly in the context of proposal voting to let users
# manage their delegations
Decidim.register_global_engine(
  :decidim_liquidvoting, # this is the name of the global method to access engine routes
  ::Decidim::Liquidvoting::Engine,
  at: "/liquidvoting"
)

# # Admin side of the delegations management. Admins can overlook all delegations and
# # create their own
# Decidim.register_global_engine(
#   :decidim_admin_liquidvoting,
#   ::Decidim::Liquidvoting::AdminEngine,
#   at: "/admin/liquidvoting"
# )
