# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class ConsultationDelegations < Rectify::Query
      def self.for(consultation, user)
        new(consultation, user).query
      end

      def initialize(consultation, user)
        @consultation = consultation
        @user = user
      end

      def query
        Delegation
          .joins(setting: :consultation)
          .where(decidim_consultations: { id: consultation.id })
          .where(grantee_id: user.id)
      end

      private

      attr_reader :consultation, :user
    end
  end
end
