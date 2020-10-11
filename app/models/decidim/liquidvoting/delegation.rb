# frozen_string_literal: true

module Decidim
  module Liquidvoting
    class Delegation < ApplicationRecord
      self.table_name = "decidim_action_delegator_delegations"

      belongs_to :granter, class_name: "Decidim::User"
      belongs_to :grantee, class_name: "Decidim::User"
      belongs_to :setting,
                 foreign_key: "decidim_action_delegator_setting_id",
                 class_name: "Decidim::Liquidvoting::Setting"

      def self.granted_to?(user, consultation)
        ConsultationDelegations.for(consultation, user).exists?
      end
    end
  end
end
