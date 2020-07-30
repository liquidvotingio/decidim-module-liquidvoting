# frozen_string_literal: true

class CreateDecidimActionDelegatorDelegations < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_action_delegator_delegations do |t|
      t.belongs_to :granter
      t.belongs_to :grantee

      t.timestamps
    end
  end
end
