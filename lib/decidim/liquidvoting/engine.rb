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
          post "delegations" => "delegations#create", as: :delegations
          delete "delegations" => "delegations#destroy"
          root to: "delegations#index"

          post "votes" => "votes#create", as: :votes
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
        app.config.assets.precompile += %w(decidim_liquidvoting_manifest.js decidim_liquidvoting_manifest.css)
      end
    end
  end
end
