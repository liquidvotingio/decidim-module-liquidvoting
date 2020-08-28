# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Admin
      module DelegationHelper
        def granters_for_select
          current_organization.users
        end

        def grantees_for_select
          current_organization.users
        end

        def consultations_for_select
          consultations.map do |consultation|
            ConsultationPresenter.new(consultation)
          end
        end

        def consultations
          Consultations::OrganizationConsultations.new(current_organization).query
        end
      end
    end
  end
end
