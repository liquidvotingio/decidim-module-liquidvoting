# frozen_string_literal: true

module Decidim::ActionDelegator
  class Delegation < ApplicationRecord
    self.table_name = "decidim_action_delegator_delegations"
  end
end
