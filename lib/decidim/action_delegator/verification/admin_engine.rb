# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Verification
      # This is the engine that runs on the public interface of `ActionDelegator`.
      class AdminEngine < ::Rails::Engine
        isolate_namespace Decidim::ActionDelegator::Verification::Admin

        paths["db/migrate"] = nil
        paths["lib/tasks"] = nil

        routes do
          # Add admin engine routes here
          resources :delegations

          root to: "delegations#index"
        end

        initializer "decidim_action_delegator.admin_assets" do |app|
          app.config.assets.precompile += %w(admin/decidim_action_delegator_manifest.js admin/decidim_action_delegator_manifest.css)
        end

        def load_seed
          nil
        end
      end
    end
  end
end
