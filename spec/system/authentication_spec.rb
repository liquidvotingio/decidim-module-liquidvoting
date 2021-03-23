# frozen_string_literal: true

require "spec_helper"

describe "Authentication", type: :system do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, password: "DfyvHn425mYAy2HL", organization: organization) }

  before do
    switch_to_host(organization.host)
    visit decidim.root_path
  end

  describe "Sign in" do
    it "doesn't break when our module is present" do
      find(".sign-in-link").click

      within ".new_user" do
        fill_in :session_user_email, with: user.email
        fill_in :session_user_password, with: "DfyvHn425mYAy2HL"
        find("*[type=submit]").click
      end

      expect(page).to have_content("Signed in successfully")
      expect(page).to have_content(user.name)
    end
  end
end
