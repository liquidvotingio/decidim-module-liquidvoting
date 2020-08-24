# frozen_string_literal: true

require "decidim/core/test/factories"

FactoryBot.define do
  factory :delegation, class: "Decidim::ActionDelegator::Delegation" do
    granter factory: :user
    grantee factory: :user
    organization
    setting
  end

  factory :setting, class: "Decidim::ActionDelegator::Setting" do
    max_grants { 3 }
    expires_at { Time.zone.now + 2.days }
    organization
  end
end
