# frozen_string_literal: true

class MakeGranterIdAndGranteeIdNonNullable < ActiveRecord::Migration[5.2]
  def change
    change_column_null :decidim_action_delegator_delegations, :granter_id, false
    change_column_null :decidim_action_delegator_delegations, :grantee_id, false
  end
end
