# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Liquidvoting
    describe Admin::DelegationsController, type: :controller do
      routes { Decidim::Liquidvoting::AdminEngine.routes }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, :admin, :confirmed, organization: organization) }

      let(:consultation) { create(:consultation, organization: organization) }
      let(:setting) { create(:setting, consultation: consultation) }

      before do
        request.env["decidim.current_organization"] = organization
        sign_in user
      end

      describe "#index" do
        let!(:delegation) { create(:delegation, setting: setting) }

        it "authorizes the action" do
          expect(controller.allowed_to?(:index, :delegation)).to eq true

          get :index, params: { setting_id: setting.id }
        end

        it "renders decidim/action_delegator/admin/delegations layout" do
          get :index
          expect(response).to render_template("layouts/decidim/action_delegator/admin/delegations")
        end

        it "renders the index template" do
          get :index, params: { setting_id: setting.id }

          expect(response).to render_template(:index)
          expect(response).to have_http_status(:ok)
        end

        it "lists delegations of the current setting" do
          other_consultation = create(:consultation, organization: organization)
          other_setting = create(:setting, consultation: other_consultation)
          other_setting_delegation = create(:delegation, setting: other_setting)

          get :index, params: { setting_id: setting.id }

          expect(assigns(:delegations)).to include(delegation)
          expect(assigns(:delegations)).not_to include(other_setting_delegation)
        end
      end

      describe "#new" do
        it "authorizes the action" do
          expect(controller).to receive(:allowed_to?).with(:create, :delegation, {})

          get :new, params: { setting_id: setting.id }
        end
      end

      describe "#create" do
        let(:granter) { create(:user, organization: organization) }
        let(:grantee) { create(:user, organization: organization) }
        let(:consultation) { create(:consultation, organization: organization) }
        let(:setting) { create(:setting, consultation: consultation) }

        let(:params) do
          { delegation: { granter_id: granter.id, grantee_id: grantee.id }, setting_id: setting.id }
        end

        it "authorizes the action" do
          expect(controller).to receive(:allowed_to?).with(:create, :delegation, {})

          post :create, params: params
        end

        context "when the setting belongs to another organization" do
          let(:setting) { create(:setting) }

          it "does not destroy the delegation" do
            expect { post :create, params: params }.not_to change(Delegation, :count)
          end
        end

        context "when successful" do
          it "creates a delegation" do
            expect { post :create, params: params }.to change(Delegation, :count).by(1)
          end

          it "redirects to the setting index" do
            post :create, params: params
            expect(response).to redirect_to(setting_delegations_path(setting))
          end
        end

        context "when failed" do
          it "shows an error" do
            post :create, params: { delegation: { granter_id: granter.id }, setting_id: setting.id }

            expect(controller).to set_flash.now[:error].to(I18n.t("decidim.action_delegator.admin.delegations.create.error"))
          end
        end
      end

      describe "#destroy" do
        let!(:delegation) { create(:delegation, setting: setting) }
        let(:params) { { id: delegation.id, setting_id: setting.id } }

        it "authorizes the action" do
          expect(controller).to receive(:allowed_to?).with(:destroy, :delegation, resource: delegation)

          delete :destroy, params: params
        end

        context "when the setting belongs to another organization" do
          let(:consultation) { create(:consultation) }
          let(:setting) { create(:setting, consultation: consultation) }
          let(:delegation) { create(:delegation) }

          it "does not destroy the delegation" do
            expect { delete :destroy, params: params }.not_to change(Delegation, :count)
          end
        end

        context "when successful" do
          it "destroys the specified delegation" do
            expect { delete :destroy, params: params }.to change(Delegation, :count).by(-1)

            expect(response).to redirect_to(setting_delegations_path(setting.id))
            expect(flash[:notice]).to eq(I18n.t("decidim.action_delegator.admin.delegations.destroy.success"))
          end
        end

        context "when failed" do
          before do
            allow_any_instance_of(Delegation).to receive(:destroy).and_return(false) # rubocop:disable RSpec/AnyInstance
          end

          it "shows an error" do
            delete :destroy, params: params

            expect(response).to redirect_to(setting_delegations_path(setting.id))
            expect(flash[:error]).to eq(I18n.t("decidim.action_delegator.admin.delegations.destroy.error"))
          end
        end
      end
    end
  end
end
