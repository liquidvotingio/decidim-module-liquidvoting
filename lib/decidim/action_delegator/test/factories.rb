# frozen_string_literal: true

require "decidim/core/test/factories"

FactoryBot.define do
  factory :delegation, class: "Decidim::ActionDelegator::Delegation" do
    granter factory: :user
    grantee factory: :user
  end
end
