# frozen_string_literal: true

require "spec_helper"

describe "Admin manages delegations", type: :system do
  let(:organization) { create(:organization) }
  let!(:user) { create(:user, :admin, :confirmed, organization: organization) }

  let!(:delegation) do
    Decidim::ActionDelegator::Delegation.create!(
      granter: create(:user),
      grantee: create(:user)
    )
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit Decidim::ActionDelegator::AdminEngine.routes.url_helpers.delegations_path
  end

  context "with existing delegations" do
    it "allows to remove a delegation" do
      within "tr[data-delegation-id=\"#{delegation.id}\"]" do
        click_link "Delete"
      end

      expect(page).to have_no_content(delegation.grantee.name)
      expect(page).to have_no_content(delegation.granter.name)
    end
  end
end
