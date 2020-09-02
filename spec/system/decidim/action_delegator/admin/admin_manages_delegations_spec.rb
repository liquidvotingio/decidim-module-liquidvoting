# frozen_string_literal: true

require "spec_helper"

describe "Admin manages delegations", type: :system do
  let(:i18n_scope) { "decidim.action_delegator.admin" }
  let(:organization) { create(:organization) }
  let(:consultation) { create(:consultation, organization: organization) }
  let!(:user) { create(:user, :admin, :confirmed, organization: organization) }

  let(:setting) { create(:setting, consultation: consultation) }
  let!(:delegation) { create(:delegation, setting: setting) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.users_path
    click_link I18n.t("decidim.action_delegator.admin.menu.delegations")
  end

  context "with existing delegations" do
    it "renders the list of delegations in a table" do
      expect(page).to have_content(I18n.t("decidim.action_delegator.admin.delegations.index.title").upcase)

      expect(page).to have_content(I18n.t("delegations.index.grantee", scope: i18n_scope).upcase)
      expect(page).to have_content(I18n.t("delegations.index.granter", scope: i18n_scope).upcase)
      expect(page).to have_content(I18n.t("delegations.index.created_at", scope: i18n_scope).upcase)

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

  context "when creating a delegation" do
    let!(:granter) { create(:user, organization: organization) }
    let!(:grantee) { create(:user, organization: organization) }
    let!(:consultation) { create(:consultation, organization: organization) }

    before do
      create(:setting)
      click_link I18n.t("delegations.index.actions.new_delegation", scope: i18n_scope)
    end

    it "creates a new delegation" do
      consultation_translated_title = Decidim::ActionDelegator::Admin::ConsultationPresenter.new(consultation).translated_title

      within ".new_delegation" do
        select granter.name, from: :delegation_granter_id
        select grantee.name, from: :delegation_grantee_id
        select setting.id, from: :delegation_decidim_action_delegator_setting_id

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      expect(page).to have_content(grantee.name)
      expect(page).to have_content(consultation_translated_title)
      expect(page).to have_current_path(decidim_admin_action_delegator.delegations_path)
    end
  end
end
