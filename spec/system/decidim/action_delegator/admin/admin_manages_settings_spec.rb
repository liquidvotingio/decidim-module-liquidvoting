# frozen_string_literal: true

require "spec_helper"

describe "Admin manages settings", type: :system do
  let(:organization) { create(:organization) }
  let!(:user) { create(:user, :admin, :confirmed, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.users_path
    click_link I18n.t("decidim.action_delegator.admin.menu.delegations")
    click_link I18n.t("decidim.action_delegator.admin.delegations.index.actions.new_setting")
  end

  it "creates new settings" do
    within ".new_setting" do
      fill_in :setting_max_grants, with: 5
      fill_in :setting_expires_at, with: 2.days.from_now.to_date

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")
    expect(page).to have_current_path(decidim_admin_action_delegator.delegations_path)
  end
end
