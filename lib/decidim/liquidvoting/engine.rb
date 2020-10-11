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
        app.config.assets.precompile += %w(decidim_liquidvoting_manifest.js decidim_liquidvoting_manifest.css)
      end

      # initializer "decidim.user_menu" do
      #   Decidim.menu :user_menu do |menu|
      #     menu.item t("vote_delegations", scope: "layouts.decidim.user_profile"),
      #               decidim_liquidvoting.user_delegations_path,
      #               position: 5.0,
      #               active: :exact
      #   end
      # end
    end
  end
end
