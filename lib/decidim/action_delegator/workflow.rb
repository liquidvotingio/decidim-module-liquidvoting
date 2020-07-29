# frozen_string_literal: true

require "decidim/verifications"

Decidim::Verifications.register_workflow(:delegations_verifier) do |workflow|
  # workflow.engine = Decidim::ActionDelegator::VerificationEngine
  workflow.admin_engine = Decidim::ActionDelegator::AdminEngine
end
