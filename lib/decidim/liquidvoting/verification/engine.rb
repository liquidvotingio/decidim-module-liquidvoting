# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Verification
      # This is the engine that runs on the public interface of `ActionDelegator`.
      class Engine < ::Rails::Engine
        isolate_namespace Decidim::ActionDelegator::Verification

        paths["db/migrate"] = nil
        paths["lib/tasks"] = nil

        routes do
          # routes
        end

        def load_seed
          # Enable the `:delegations_verifier` authorization
          org = Decidim::Organization.first
          org.available_authorizations << :delegations_verifier
          org.save!
        end
      end
    end
  end
end
