# frozen_string_literal: true

module Decidim
  module ActionDelegator
    # Contains the delegation settings of a consultation. Rather than a single attribute here
    # a setting is the record itself: a bunch of configuration values.
    class Setting < ApplicationRecord
      self.table_name = "decidim_action_delegator_settings"

      belongs_to :consultation,
                 foreign_key: "decidim_consultation_id",
                 class_name: "Decidim::Consultation"

      validate :expires_at_in_the_future

      validates :max_grants, :expires_at, presence: true
      validates :max_grants, numericality: { greater_than: 0 }

      private

      def expires_at_in_the_future
        errors.add(:expires_at, "can't be in the past") if expires_at.present? && expires_at < Time.current
      end
    end
  end
end
