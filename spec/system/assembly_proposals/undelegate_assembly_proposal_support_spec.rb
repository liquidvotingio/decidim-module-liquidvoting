# frozen_string_literal: true

require "spec_helper"

describe "Undelegating support for a Proposal", type: :system do
  let(:organization) { create(:organization) }
  let(:assembly) { create(:assembly, organization: organization) }
  let(:assembly_proposals_component) { create(:component, participatory_space: assembly, manifest_name: :proposals) }
  let(:assembly_proposal) { create :proposal, component: assembly_proposals_component }

  let(:user) { create(:user, :confirmed, organization: organization) }
  let(:delegate) { create(:user, :confirmed, organization: organization) }

  def visit_proposal
    visit resource_locator(assembly_proposal).url # path gives a RoutingError
  end

  before do
    login_as user, scope: :user
    visit_proposal
    select delegate.name, from: "delegate_id"
    click_button "Delegate Support"
  end

  it "works" do
    click_button "Withdraw Delegation"

    expect(page).to have_button("Support", id: "vote_button-#{assembly_proposal.id}")
    expect(page).to have_button("Delegate Support")
    expect(page).to have_select("delegate_id")
    expect(page).to have_text(:visible, /Or delegate your support:/)
  end
end
