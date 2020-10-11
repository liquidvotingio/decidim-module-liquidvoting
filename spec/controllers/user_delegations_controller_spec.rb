# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Liquidvoting
    describe UserDelegationsController, type: :controller do
      routes { Decidim::Liquidvoting::Engine.routes }

      let(:organization) { create :organization }
      let(:user) { create(:user, :confirmed, organization: organization) }

      before do
        request.env["decidim.current_organization"] = organization
        sign_in user
      end

      describe "get #index" do
        it "show the list of delegations for the user" do
          get :index
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end
end
