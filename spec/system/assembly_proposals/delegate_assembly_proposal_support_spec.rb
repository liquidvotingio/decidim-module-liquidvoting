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

  let!(:user) { create(:user, :confirmed, organization: organization) }
  let(:manifest_name) { :assemblies }
  let!(:assembly_proposal) { create :proposal, component: component }
  let!(:delegate) { create(:user, :confirmed, organization: organization) }

  def visit_proposal
    visit resource_locator(assembly_proposal).path
  end

  before do
    login_as user, scope: :user
    visit_proposal
  end

  it "works" do
    select delegate.name, from: "delegate_id"
    click_button "Delegate Support"

    expect(page).to have_button("Withdraw Delegation")
    expect(page).not_to have_select("delegate_id")
    expect(page).to have_text(:visible, /You delegated to: #{delegate.name}/, normalize_ws: true)
    expect(page).to have_button("Support", id: "vote_button-#{assembly_proposal.id}", disabled: true)
  end

  it "alerts and does not send request when no delegate selected" do
    expect(Decidim::Liquidvoting).not_to receive(:create_delegation)

    msg = accept_alert { click_button "Delegate Support" }

    expect(msg).to match(/Please first choose your delegate/)
  end
end
