# frozen_string_literal: true

require "spec_helper"

describe "Admin manages delegations", type: :system do
  let(:i18n_scope) { "decidim.action_delegator.admin" }
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }

  context "when listing settings" do
    let(:consultation) { create(:consultation, organization: organization) }
    let!(:setting) { create(:setting, consultation: consultation) }

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin.users_path
      click_link I18n.t("decidim.action_delegator.admin.menu.delegations")
    end

    it "renders the list of consultation settings in a table" do
      expect(page).to have_content(I18n.t("decidim.action_delegator.admin.delegations.index.title").upcase)

      expect(page).to have_content(I18n.t("settings.index.consultation", scope: i18n_scope).upcase)
      expect(page).to have_content(I18n.t("settings.index.created_at", scope: i18n_scope).upcase)

      expect(page).to have_content(Decidim::ActionDelegator::Admin::ConsultationPresenter.new(setting.consultation).translated_title)
      expect(page).to have_content(I18n.l(setting.created_at, format: :short))
    end

    it "allows to remove a setting" do
      within "tr[data-setting-id=\"#{setting.id}\"]" do
        accept_confirm { click_link "Delete" }
      end

      expect(page).to have_current_path(decidim_admin_action_delegator.settings_path)
      expect(page).to have_no_content(Decidim::ActionDelegator::Admin::ConsultationPresenter.new(setting.consultation).translated_title)
    end
  end

  context "when creating a delegation" do
    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin.users_path
      click_link I18n.t("decidim.action_delegator.admin.menu.delegations")
    end

    let!(:granter) { create(:user, organization: organization) }
    let!(:grantee) { create(:user, organization: organization) }
    let!(:consultation) { create(:consultation, organization: organization) }

    it "creates a new setting and a delegation for a consultation" do
      expect(page).to have_current_path(decidim_admin_action_delegator.settings_path)

      click_link I18n.t("settings.index.actions.new_delegation", scope: i18n_scope)

      consultation_translated_title = Decidim::ActionDelegator::Admin::ConsultationPresenter.new(consultation).translated_title
      within ".new_setting" do
        select consultation_translated_title, from: :setting_decidim_consultation_id
        fill_in :setting_max_grants, with: 5
        fill_in :setting_expires_at, with: 2.days.from_now.to_date

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      expect(page).to have_current_path(decidim_admin_action_delegator.settings_path)

      click_link consultation_translated_title

      setting = Decidim::ActionDelegator::Setting.last
      expect(page).to have_current_path(decidim_admin_action_delegator.setting_delegations_path(setting.id))

      click_link I18n.t("settings.index.actions.new_delegation", scope: i18n_scope)

      within ".new_delegation" do
        select granter.name, from: :delegation_granter_id
        select grantee.name, from: :delegation_grantee_id
        select setting.id, from: :delegation_decidim_action_delegator_setting_id

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      expect(page).to have_content(grantee.name)
      expect(page).to have_content(consultation_translated_title)
      expect(page).to have_current_path(decidim_admin_action_delegator.setting_delegations_path(setting.id))
    end
  end
end
