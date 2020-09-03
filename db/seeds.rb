# frozen_string_literal: true

Decidim::ActionDelegator::Delegation.create(
  granter: Decidim::User.first,
  grantee: Decidim::User.second,
  setting: Decidim::ActionDelegator::Setting.first
)
