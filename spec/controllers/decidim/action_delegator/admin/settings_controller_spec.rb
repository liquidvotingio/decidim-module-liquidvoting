# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ActionDelegator
    describe Admin::SettingsController, type: :controller do
      routes { Decidim::ActionDelegator::AdminEngine.routes }

      let(:organization) { create(:organization) }
      let(:consultation) { create(:consultation, organization: organization) }
      let(:user) { create(:user, :admin, :confirmed, organization: organization) }

      before do
        request.env["decidim.current_organization"] = organization
        sign_in user
      end

      describe "#create" do
        let(:setting_params) do
          { setting: { max_grants: 2, expires_at: 2.days.from_now.to_date, decidim_consultation_id: consultation.id } }
        end

        context "when successful" do
          it "creates new settings" do
            expect { post :create, params: setting_params }.to change(Setting, :count).by(1)

            expect(response).to redirect_to(delegations_path)
            expect(flash[:notice]).to eq(I18n.t("decidim.action_delegator.admin.settings.create.success"))
          end
        end

        context "when failed" do
          it "shows the error" do
            post :create, params: { setting: { max_grants: 2 } }

            expect(flash[:error]).to eq(I18n.t("decidim.action_delegator.admin.settings.create.error"))
          end
        end
      end
    end
  end
end
