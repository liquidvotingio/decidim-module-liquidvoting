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
        # resources :action_delegator
      end

      initializer "decidim_action_delegator.assets" do |app|
        app.config.assets.precompile += %w(decidim_action_delegator_manifest.js decidim_action_delegator_manifest.css)
      end
    end
  end
end
