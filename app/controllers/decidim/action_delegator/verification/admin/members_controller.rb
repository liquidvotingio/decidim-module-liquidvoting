# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Verification
      module Admin
        class MembersController < ActionDelegator::Verification::Admin::ApplicationController
          include NeedsPermission

          layout "decidim/admin/users"

          def index
            # some permissions
          end
        end
      end
    end
  end
end
