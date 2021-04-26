# frozen_string_literal: true

require "spec_helper"

# Test to confirm that a proposal card in the proposals index view does not include the 'Support'
# button or our 'Delegate Support' button, even when these are visible in the show proposal view.
describe "View a Proposal by clicking 'view proposal' on index view proposal card", type: :system do
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

  before do
    login_as user, scope: :user
    visit_component
  end

  it "works" do
    expect(page).to have_content("PROPOSALS")
    expect(page).to have_content("VIEW PROPOSAL")
    expect(page).not_to have_button("Support")
    expect(page).not_to have_button("Delegate Support")
    click_link("View proposal")
    expect(page).to have_button("Support", id: "vote_button-#{proposal.id}")
    expect(page).to have_button("Delegate Support")
  end
end