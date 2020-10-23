# frozen_string_literal: true

module Decidim
  module Liquidvoting
    module Admin
      # This controller is the abstract class from which all other controllers of
      # this engine inherit.
      class ApplicationController < Decidim::Admin::ApplicationController
        register_permissions(ApplicationController,
                             Liquidvoting::Permissions,
                             Decidim::Admin::Permissions)
        def permission_class_chain
          Decidim.permissions_registry.chain_for(ApplicationController)
        end
        
        def index
          respond_to do |format|
            format.html { render html: "<p>placeholder admin page</p>".html_safe }
          end
        end
      end
    end
  end
end
