# frozen_string_literal: true

require "spec_helper"

describe "Admin manages settings", type: :system do
  let(:i18n_scope) { "decidim.action_delegator.admin" }
  let(:organization) { create(:organization) }
  let!(:consultation) { create(:consultation, organization: organization) }
  let!(:user) { create(:user, :admin, :confirmed, organization: organization) }

  let(:consultation_translated_title) { Decidim::ActionDelegator::Admin::ConsultationPresenter.new(consultation).translated_title }

  context "when creating settings" do
    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin.users_path
      click_link I18n.t("decidim.action_delegator.admin.menu.delegations")

      click_link I18n.t("decidim.action_delegator.admin.settings.index.actions.new_setting")
    end

    it "creates a new setting" do
      within ".new_setting" do
        fill_in :setting_max_grants, with: 5
        fill_in :setting_expires_at, with: 2.days.from_now.to_date
        select consultation_translated_title, from: :setting_decidim_consultation_id

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      expect(page).to have_content(consultation_translated_title)
      expect(page).to have_current_path(decidim_admin_action_delegator.settings_path)
    end
  end

  context "when listing settings" do
    let!(:setting) { create(:setting, consultation: consultation) }

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin.users_path
      click_link I18n.t("decidim.action_delegator.admin.menu.delegations")
    end

    it "renders the list of settings in a table" do
      expect(page).to have_content(I18n.t("decidim.action_delegator.admin.delegations.index.title").upcase)

      expect(page).to have_content(I18n.t("settings.index.consultation", scope: i18n_scope).upcase)
      expect(page).to have_content(I18n.t("settings.index.created_at", scope: i18n_scope).upcase)

      expect(page).to have_content(consultation_translated_title)
      expect(page).to have_content(I18n.l(setting.created_at, format: :short))
    end

    it "links to the setting" do
      click_link consultation_translated_title
      expect(page).to have_current_path(decidim_admin_action_delegator.setting_delegations_path(setting))
    end
  end

  context "when removing settings" do
    let!(:setting) { create(:setting, consultation: consultation) }
    let!(:delegation) { create(:delegation, setting: setting) }

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin.users_path
      click_link I18n.t("decidim.action_delegator.admin.menu.delegations")
    end

    it "removes the setting" do
      within "tr[data-setting-id=\"#{setting.id}\"]" do
        accept_confirm { click_link "Delete" }
      end

      expect(page).to have_current_path(decidim_admin_action_delegator.settings_path)
      expect(page).to have_no_content(consultation_translated_title)
    end
  end
end
