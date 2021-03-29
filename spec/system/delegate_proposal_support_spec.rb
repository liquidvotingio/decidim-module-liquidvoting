# frozen_string_literal: true

require "spec_helper"

describe "Delegating support for a Proposal", type: :system do
  include_context "with a component"
  let!(:component) do
    create(
      :proposal_component,
      :with_votes_enabled,
      participatory_space: participatory_space
    )
  end
  let!(:proposal) { create :proposal, component: component }
  let!(:user) { create(:user, :confirmed, organization: organization) }
  let!(:delegate) { create(:user, :confirmed, organization: organization) }

  def visit_proposal
    visit resource_locator(proposal).path
  end

  before do
    login_as user, scope: :user
    visit_proposal
  end

  it "works" do
    select delegate.name, from: "delegate_email"
    click_button "Delegate Support"
    expect(page).to have_button("Withdraw Delegation")
    expect(page).not_to have_select("delegate_email")
    expect(page).to have_text(:visible, /You delegated to: #{delegate.name}/, normalize_ws: true)
    expect(page).to have_button("Support", id: "vote_button-#{proposal.id}", disabled: true)
  end
end
