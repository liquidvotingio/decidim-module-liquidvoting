# frozen_string_literal: true

module Decidim
  module Liquidvoting
    module Admin
      # This controller is the abstract class from which all other controllers of
      # this engine inherit.
      class ApplicationController < Decidim::Admin::ApplicationController
        register_permissions(::Decidim::Liquidvoting::Admin::ApplicationController,
                             ::Decidim::Liquidvoting::Permissions,
                             ::Decidim::Admin::Permissions)
        def permission_class_chain
          ::Decidim.permissions_registry.chain_for(::Decidim::Liquidvoting::Admin::ApplicationController)
        end
      end
    end
  end
end
