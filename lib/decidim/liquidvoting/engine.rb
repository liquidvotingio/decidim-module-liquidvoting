# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module Liquidvoting
    # This is the engine that runs on the public interface of liquidvoting.
    # Handles all the logic related to delegation except verifications
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Liquidvoting

      routes do
        # Add engine routes here
        authenticate(:user) do
          proposal_delegation_path = "/processes/:participatory_process_slug/f/:component_id/proposals/:id/delegations"
          post proposal_delegation_path => "proposal_vote_delegations#create", as: :delegations
          delete proposal_delegation_path => "proposal_vote_delegations#destroy"
        end
      end

      # Initializer must go here otherwise every engine triggers config/initializers/ files
      initializer "decidim_liquidvoting.overrides" do |_app|
        Rails.application.config.to_prepare do
          Dir.glob("#{Decidim::Liquidvoting::Engine.root}/app/overrides/**/*.rb").each do |c|
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
