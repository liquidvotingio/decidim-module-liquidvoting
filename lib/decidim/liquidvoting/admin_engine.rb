# frozen_string_literal: true

module Decidim
  module Liquidvoting
    # This is the engine that runs on the public interface of `Liquidvoting`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Liquidvoting::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :settings, only: [:index, :new, :create, :destroy] do
          resources :delegations, only: [:index, :new, :create, :destroy]
        end

        root to: "delegations#index"
      end

      initializer "decidim_liquidvoting.admin_assets" do |app|
        app.config.assets.precompile += %w(admin/decidim_liquidvoting_manifest.js admin/decidim_liquidvoting_manifest.css)
      end

      def load_seed
        nil
      end
    end
  end
end
