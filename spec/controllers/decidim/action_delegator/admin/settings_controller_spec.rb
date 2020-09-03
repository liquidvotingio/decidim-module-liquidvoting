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

      describe "#index" do
        it "authorizes the action" do
          expect(controller).to receive(:allowed_to?).with(:index, :setting, {})

          get :index
        end

        it "renders decidim/admin/users layout" do
          get :index
          expect(response).to render_template("layouts/decidim/admin/users")
        end

        it "lists settings of the current organization only" do
          other_consultation = create(:consultation)
          other_setting = create(:setting, consultation: other_consultation)

          get :index

          expect(assigns(:settings)).not_to include(other_setting)
        end
      end

      describe "#new" do
        it "authorizes the action" do
          expect(controller).to receive(:allowed_to?).with(:create, :setting, {})

          get :new
        end
      end

      describe "#create" do
        let(:setting_params) do
          { setting: { max_grants: 2, expires_at: 2.days.from_now.to_date, decidim_consultation_id: consultation.id } }
        end

        it "authorizes the action" do
          expect(controller).to receive(:allowed_to?).with(:create, :setting, {})

          post :create, params: setting_params
        end

        context "when successful" do
          it "creates new settings" do
            expect { post :create, params: setting_params }.to change(Setting, :count).by(1)

            expect(response).to redirect_to(settings_path)
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

      describe "#destroy" do
        let!(:setting) { create(:setting, consultation: consultation) }

        it "authorizes the action" do
          expect(controller).to receive(:allowed_to?).with(:destroy, :setting, resource: setting)

          delete :destroy, params: { id: setting.id }
        end

        context "when the specified setting does not belong to the current organization" do
          let(:consultation) { create(:consultation) }
          let(:setting) { create(:setting, consultation: consultation) }

          it "does not destroy the setting" do
            expect { delete :destroy, params: { id: setting.id } }
              .not_to change(Setting, :count)
          end
        end

        context "when successful" do
          it "destroys the specified setting" do
            expect { delete :destroy, params: { id: setting.id } }
              .to change(Setting, :count).by(-1)

            expect(response).to redirect_to(settings_path)
            expect(flash[:notice]).to eq(I18n.t("decidim.action_delegator.admin.settings.destroy.success"))
          end
        end

        context "when failed" do
          before do
            allow_any_instance_of(Setting).to receive(:destroy).and_return(false) # rubocop:disable RSpec/AnyInstance
          end

          it "shows an error" do
            delete :destroy, params: { id: setting.id }

            expect(response).to redirect_to(settings_path)
            expect(flash[:error]).to eq(I18n.t("decidim.action_delegator.admin.settings.destroy.error"))
          end
        end
      end
    end
  end
end
