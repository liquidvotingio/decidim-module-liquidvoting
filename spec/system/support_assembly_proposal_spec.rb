# frozen_string_literal: true

require "spec_helper"

describe "Supporting an Assembly Proposal", type: :system do
  include_context "with a component"
  let!(:component) do
    create(
      :proposal_component,
      :with_votes_enabled,
      participatory_space: participatory_space
    )
  end

  let!(:user) { create(:user, :confirmed, organization: organization) }

  let!(:assembly) do
    create(
      :assembly,
      :with_type,
      organization: organization,
      description: { en: "Description", ca: "Descripció", es: "Descripción" },
      short_description: { en: "Short description", ca: "Descripció curta", es: "Descripción corta" },
      show_statistics: true
    )
  end
  let(:manifest_name) { :assemblies }
  let!(:proposals_component) { create(:component, :published, participatory_space: assembly, manifest_name: :proposals) }
  let!(:assembly_proposal) { create :proposal, component: component }

  def visit_assembly_proposal
    visit resource_locator(assembly_proposal).path
  end

  before do
    login_as user, scope: :user
    visit_assembly_proposal
  end

  it "works" do
    click_button("Support", id: "vote_button-#{assembly_proposal.id}")

    expect(page).to have_button("Already supported")
    expect(page).not_to have_select("delegate_id")
    expect(page).to have_button("Delegate Support", disabled: true)
  end
end
