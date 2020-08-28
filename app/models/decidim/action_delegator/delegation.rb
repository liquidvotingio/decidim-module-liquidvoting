# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class Delegation < ApplicationRecord
      self.table_name = "decidim_action_delegator_delegations"

      belongs_to :granter, class_name: "Decidim::User"
      belongs_to :grantee, class_name: "Decidim::User"
      belongs_to :setting,
                 foreign_key: "decidim_action_delegator_settings_id",
                 class_name: "Decidim::ActionDelegator::Setting"
      belongs_to :organization,
                 foreign_key: "decidim_organization_id",
                 class_name: "Decidim::Organization"
      belongs_to :consultation,
                 foreign_key: "decidim_consultation_id",
                 class_name: "Decidim::Consultation"
    end
  end
end
