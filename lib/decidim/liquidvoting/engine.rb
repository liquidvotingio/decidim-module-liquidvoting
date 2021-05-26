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

          assembly_proposal_delegation_path = "/assemblies/:assembly_slug/f/:component_id/proposals/:id/delegations"
          post assembly_proposal_delegation_path => "proposal_vote_delegations#create", as: :assembly_delegations
          delete assembly_proposal_delegation_path => "proposal_vote_delegations#destroy"
        end
      end

      initializer "decidim_liquidvoting.add_cells_view_paths" do
        Cell::ViewModel.view_paths.unshift File.expand_path("#{Decidim::Liquidvoting::Engine.root}/app/cells")
      end

      # Initializer must go here otherwise every engine triggers config/initializers/ files
      initializer "decidim_liquidvoting.overrides" do |_app|
        Rails.logger.info "######################"
        Rails.logger.info ""
        Rails.logger.info ""
        Rails.logger.info "Liquidvoting: initializer 'decidim_liquidvoting.overrides', glob is \"#{Decidim::Liquidvoting::Engine.root}/app/overrides/**/*.rb\""
        Rails.logger.info ""
        Rails.logger.info ""
        Rails.logger.info "######################"
        Rails.application.config.to_prepare do
          Dir.glob("#{Decidim::Liquidvoting::Engine.root}/app/overrides/**/*.rb").each do |c|
            Rails.logger.info "  Liquidvoting about to require_dependency: #{c}"
            require_dependency(c)
          end
        end
        Rails.logger.info ""
        Rails.logger.info "######################"
      end

      initializer "decidim_liquidvoting.assets" do |app|
        app.config.assets.precompile += %w(
          decidim_liquidvoting_manifest.js decidim_liquidvoting_manifest.css
        )
      end
    end
  end
end
