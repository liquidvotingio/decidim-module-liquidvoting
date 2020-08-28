# frozen_string_literal: true

class AddConsultationIdToDelegations < ActiveRecord::Migration[5.2]
  def change
    add_belongs_to :decidim_action_delegator_delegations,
                   :decidim_consultation,
                   null: false,
                   foreign_key: true,
                   index: { name: "index_decidim_delegations_on_consultation_id" }
  end
end
