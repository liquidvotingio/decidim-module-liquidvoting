# frozen_string_literal: true

require "decidim/verifications"

Decidim::Verifications.register_workflow(:delegations_verifier) do |workflow|
  workflow.engine = Decidim::ActionDelegator::Verification::Engine
  workflow.admin_engine = Decidim::ActionDelegator::Verification::AdminEngine
end
