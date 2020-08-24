# frozen_string_literal: true

class AddSettingsIdToDelegations < ActiveRecord::Migration[5.2]
  def change
    add_belongs_to :decidim_action_delegator_delegations,
                   :decidim_action_delegator_settings,
                   foreign_key: true,
                   index: { name: "index_decidim_delegations_on_settings_id" }
  end
end
