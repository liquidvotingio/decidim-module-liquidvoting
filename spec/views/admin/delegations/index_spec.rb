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
    render

    expect(rendered).to include(delegation.granter)
    expect(rendered).to include(delegation.grantee)
  end
end
