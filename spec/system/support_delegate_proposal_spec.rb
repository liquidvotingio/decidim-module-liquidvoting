# frozen_string_literal: true

require "spec_helper"

describe "Supporting and Delegating a Proposal", type: :system do
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

  def visit_proposal
    visit resource_locator(proposal).path
  end

  context "when the user is not logged in" do
    before do
      visit_proposal
    end

    it "can be supported" do
      expect(page).to have_button("Support")
    end

    it "can NOT be delegated" do
      expect(page).to_not have_button("Delegate Support")
    end
  end

  context "when the user is logged in" do
    before do
      login_as user, scope: :user
    end

    context "when the proposal is not yet supported or delegated" do
      before do
        visit_proposal
      end

      it "can be supported" do
        expect(page).to have_button("Support", id: "vote_button-#{proposal.id}", disabled: false)
      end

      it "can be delegated" do
        expect(page).to have_button("Delegate Support", disabled: false)
      end
    end

    context "when the proposal has been supported"
    context "when the proposal has been delegated"
  end
end
