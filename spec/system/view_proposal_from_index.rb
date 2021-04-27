# frozen_string_literal: true

require "spec_helper"

# Test to confirm that override presenting the Support button on a proposal card in the proposals
# index view, because we don't yet have a good liquidvoting UI for doing that from the Proposals
# list page. Instead, we want to replace the voting related elements with a View Proposal button.
describe "Viewing the Proposals list", type: :system do
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

  it "replaces the voting footer on the proposal card with a View Proposal button" do
    expect(page).to have_content("PROPOSALS")
    expect(page).to have_content("VIEW PROPOSAL")
    expect(page).not_to have_button("Support")
    expect(page).not_to have_button("Delegate Support")
  end

  it "goes to the Proposal page when clicking View Proposal button" do
    click_link("View proposal")
    expect(page).to have_button("Support", id: "vote_button-#{proposal.id}")
    expect(page).to have_button("Delegate Support")
  end
end
