# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module ActionDelegator
    # This is the engine that runs on the public interface of action_delegator.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::ActionDelegator

      routes do
        # Add engine routes here
        authenticate(:user) do
          resources :user_delegations, controller: :user_delegations
          root to: "user_delegations#index"
        end
      end

      initializer "decidim_action_delegator.assets" do |app|
        app.config.assets.precompile += %w(decidim_action_delegator_manifest.js decidim_action_delegator_manifest.css)
      end

      initializer "decidim.user_menu" do
        Decidim.menu :user_menu do |menu|
          menu.item t("vote_delegations", scope: "layouts.decidim.user_profile"),
                    decidim_action_delegator.user_delegations_path,
                    position: 5.0,
                    active: :exact
        end
      end
    end
  end
end
