# frozen_string_literal: true

require "spec_helper"

describe "decidim/action_delegator/admin/delegations/index", type: :view do
  let(:delegation) do
    Decidim::ActionDelegator::Delegation.create!(
      granter: create(:user),
      grantee: create(:user)
    )
  end

  it "renders the list of delegations" do
    render template: subject, locals: { delegations: [delegation] }

    expect(rendered).to include(delegation.granter.name)
    expect(rendered).to include(delegation.grantee.name)
    expect(rendered).to include(I18n.l(delegation.created_at, format: :short))
  end

  it "renders a table with header" do
    render template: subject, locals: { delegations: [delegation] }

    expect(rendered).to include(I18n.t("decidim.action_delegator.admin.delegations.index.grantee"))
    expect(rendered).to include(I18n.t("decidim.action_delegator.admin.delegations.index.granter"))
    expect(rendered).to include(I18n.t("decidim.action_delegator.admin.delegations.index.created_at"))
  end

  it "renders a card wrapper with the title" do
    render template: subject, locals: { delegations: [delegation] }

    expect(rendered).to include(I18n.t("decidim.action_delegator.admin.delegations.index.title"))
  end
end
