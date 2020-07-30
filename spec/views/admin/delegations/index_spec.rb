# frozen_string_literal: true

require "spec_helper"

describe "decidim/action_delegator/admin/delegations/index", type: :view do
  let(:delegation) do
    Decidim::ActionDelegator::Delegation.new(
      granter: create(:user),
      grantee: create(:user)
    )
  end

  it "renders the list of delegations" do
    assign(:delegations, [delegation])

    render

    expect(rendered).to match(delegation.granter.name)
    expect(rendered).to match(delegation.grantee.name)
  end
end
