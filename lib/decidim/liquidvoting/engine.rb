# frozen_string_literal: true

require "rails"
require "decidim/core"
# require "decidim/consultations"

module Decidim
  module Liquidvoting
    # This is the engine that runs on the public interface of liquidvoting.
    # Handles all the logic related to delegation except verifications
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Liquidvoting

      routes do
        # Add engine routes here
        authenticate(:user) do
          # post "/:spacetype/:spaceslug/f/:component_id/proposals/:id/delegations" => "delegations#create", as: :delegations
          post "/processes/:participatory_process_slug/f/:component_id/proposals/:id/delegations" => "delegations#create", as: :delegations
          delete "/processes/:participatory_process_slug/f/:component_id/proposals/:id/delegations" => "delegations#destroy"
          # To generalise, have to either manually make routes for each case, or find a clever way to generate
          # post "/processes/:participatory_process_slug/f/:component_id/budgets/:id/delegations" => "delegations#create", as: :delegations
          # delete "/processes/:participatory_process_slug/f/:component_id/budgets/:id/delegations" => "delegations#destroy"
          # post "delegations" => "delegations#create", as: :delegations
          # delete "delegations" => "delegations#destroy"
          root to: "delegations#index"
        end
      end

      # Initializer must go here otherwise every engine triggers config/initializers/ files
      initializer "decidim_liquidvoting.overrides" do |_app|
        Rails.application.config.to_prepare do
          Dir.glob(Decidim::Liquidvoting::Engine.root + "app/overrides/**/*.rb").each do |c|
            require_dependency(c)
          end
        end
      end

      initializer "decidim_liquidvoting.assets" do |app|
        app.config.assets.precompile += %w(
          decidim_liquidvoting_manifest.js decidim_liquidvoting_manifest.css
        )
      end
    end
  end
end
