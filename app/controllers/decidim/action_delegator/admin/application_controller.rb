# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Admin
      # This controller is the abstract class from which all other controllers of
      # this engine inherit.
      class ApplicationController < Decidim::Admin::ApplicationController
        register_permissions(::Decidim::ActionDelegator::Admin::ApplicationController,
                             ::Decidim::ActionDelegator::Permissions,
                             ::Decidim::Admin::Permissions)
        
        def permission_class_chain
          ::Decidim.permissions_registry.chain_for(::Decidim::ActionDelegator::Admin::ApplicationController)
        end
      end
    end
  end
end
