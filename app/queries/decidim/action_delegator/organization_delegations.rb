# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class OrganizationDelegations < Rectify::Query
      def self.for(organization)
        new(organization).query
      end

      def initialize(organization)
        @organization = organization
      end

      def query
        Delegation
          .includes(:grantee, :granter)
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
