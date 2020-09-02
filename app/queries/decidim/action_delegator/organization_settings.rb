# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class OrganizationSettings < Rectify::Query
      def initialize(organization)
        @organization = organization
      end

      def query
        Setting
          .joins(:consultation)
          .merge(organization_consultations)
      end

      private

      attr_reader :organization

      def organization_consultations
        Consultations::OrganizationConsultations.new(organization).query
      end
    end
  end
end
