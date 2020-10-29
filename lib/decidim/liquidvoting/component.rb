# frozen_string_literal: true

require_dependency "decidim/components/namer"

Decidim.register_component(:liquidvoting) do |component|
  component.engine = Decidim::Liquidvoting::Engine
  component.admin_engine = Decidim::Liquidvoting::AdminEngine
  component.icon = "decidim/liquidvoting/icon.svg"

  component.permissions_class_name = "Decidim::Liquidvoting::Permissions"
end

# User space engine, used mostly in the context of proposal voting to let users
# manage their delegations
Decidim.register_global_engine(
  :liquidvoting, # this is the name of the global method to access engine routes
  Decidim::Liquidvoting::Engine,
  at: "/liquidvoting"
)

# # Admin side of the delegations management. Admins can overlook all delegations and
# # create their own
# Decidim.register_global_engine(
#   :decidim_admin_liquidvoting,
#   ::Decidim::Liquidvoting::AdminEngine,
#   at: "/admin/liquidvoting"
# )
