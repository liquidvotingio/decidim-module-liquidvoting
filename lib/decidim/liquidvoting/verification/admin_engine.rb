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
          resources :members

          root to: "members#index"
        end

        def load_seed
          nil
        end
      end
    end
  end
end
