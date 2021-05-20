# frozen_string_literal: true

require "spec_helper"

describe "Unsupporting a Proposal", type: :system do
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

  def visit_proposal
    visit resource_locator(assembly_proposal).path
  end

  before do
    login_as user, scope: :user
    visit_proposal
    click_button("Support", id: "vote_button-#{assembly_proposal.id}")
  end

  it "works" do
    click_button("Already supported", id: "vote_button-#{assembly_proposal.id}")

    expect(page).to have_button("Support", id: "vote_button-#{assembly_proposal.id}")
    expect(page).to have_button("Delegate Support")
    expect(page).to have_select("delegate_id")
    expect(page).to have_text(:visible, /Or delegate your support:/)
  end
end
