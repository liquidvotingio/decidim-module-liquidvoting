# frozen_string_literal: true

require "decidim/action_delegator/admin"
require "decidim/action_delegator/engine"
require "decidim/action_delegator/admin_engine"

module Decidim
  # This namespace holds the logic of the `ActionDelegator` module
  module ActionDelegator
  end
end

Decidim.register_global_engine(
  :decidim_action_delegator, # this is the name of the global method to access engine routes
  ::Decidim::ActionDelegator::Engine,
  at: "/action_delegator"
)
