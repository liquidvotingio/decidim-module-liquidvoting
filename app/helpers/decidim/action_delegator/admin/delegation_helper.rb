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
          organization_consultations.map do |consultation|
            ConsultationPresenter.new(consultation)
          end
        end

        def settings_for_select
          OrganizationSettings.new(current_organization).query
        end

        def organization_consultations
          Consultations::OrganizationConsultations.new(current_organization).query
        end
      end
    end
  end
end
