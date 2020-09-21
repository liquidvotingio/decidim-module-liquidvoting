# frozen_string_literal: true

require "spec_helper"

describe "Delegation vote", type: :system do
  let(:organization) { create(:organization) }
  let(:question) { create :question, :published, consultation: consultation }

  context "when active consultation" do
    let(:consultation) { create(:consultation, :active, organization: organization) }
    let(:user) { create(:user, :confirmed, organization: organization) }

    context "and authenticated user" do
      context "and never voted before" do
        let!(:response) { create :response, question: question }
        let(:setting) { create(:setting, consultation: consultation) }
        let(:granter) { create(:user, :confirmed, organization: organization) }
        let!(:delegation) { create(:delegation, setting: setting, granter: granter, grantee: user) }

        before do
          switch_to_host(organization.host)
          login_as user, scope: :user
          visit decidim_consultations.question_path(question)
        end

        it "lets the user vote on behalf of some other member" do
          click_link(id: "delegations-button")
          click_link(class: "delegation-vote-button")

          expect(page).to have_content(I18n.t("decidim.action_delegator.delegations_modal.callout"))

          click_button translated(response.title)
          click_button "Confirm"

          expect(page).to have_button(class: "delegation_unvote_button", visible: :hidden)
        end
      end
    end
  end
end
