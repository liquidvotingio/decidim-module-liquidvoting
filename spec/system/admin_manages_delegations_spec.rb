# frozen_string_literal: true

require "spec_helper"

describe "Admin manages delegations", type: :system do
  let(:organization) { create(:organization) }
  let!(:user) { create(:user, :admin, :confirmed, organization: organization) }

  let!(:delegation) { create(:delegation, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    # visit decidim_admin_action_delegator.delegations_path
    visit decidim_admin.users_path
    click_link I18n.t("decidim.action_delegator.admin.menu.delegations")
  end

  context "with existing delegations" do
    it "renders a card wrapper with the title" do
      expect(page).to have_content(I18n.t("decidim.action_delegator.admin.delegations.index.title").upcase)
    end

    it "renders a table with header" do
      expect(page).to have_content(I18n.t("decidim.action_delegator.admin.delegations.index.grantee").upcase)
      expect(page).to have_content(I18n.t("decidim.action_delegator.admin.delegations.index.granter").upcase)
      expect(page).to have_content(I18n.t("decidim.action_delegator.admin.delegations.index.created_at").upcase)
    end

    it "renders the list of delegations" do
      expect(page).to have_content(delegation.granter.name)
      expect(page).to have_content(delegation.grantee.name)
      expect(page).to have_content(I18n.l(delegation.created_at, format: :short))
    end

    it "allows to remove a delegation" do
      within "tr[data-delegation-id=\"#{delegation.id}\"]" do
        accept_confirm { click_link "Delete" }
      end

      expect(page).to have_no_content(delegation.grantee.name)
      expect(page).to have_no_content(delegation.granter.name)
    end
  end
end
