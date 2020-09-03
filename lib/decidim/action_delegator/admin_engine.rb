# frozen_string_literal: true

module Decidim
  module ActionDelegator
    # This is the engine that runs on the public interface of `ActionDelegator`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::ActionDelegator::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :delegations, only: [:index, :new, :create, :destroy]
        resources :settings, only: [:new, :create]

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
