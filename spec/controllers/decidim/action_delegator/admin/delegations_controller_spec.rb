# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ActionDelegator
    describe Admin::DelegationsController, type: :controller do
      routes { Decidim::ActionDelegator::AdminEngine.routes }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, :admin, :confirmed, organization: organization) }

      let(:consultation) { create(:consultation, organization: organization) }
      let(:setting) { create(:setting, consultation: consultation) }
      let!(:delegation) { create(:delegation, setting: setting) }

      before do
        request.env["decidim.current_organization"] = organization
        sign_in user
      end

      describe "#index" do
        it "authorizes the action" do
          expect(controller.allowed_to?(:index, :delegation)).to eq true

          get :index, params: { setting_id: setting.id }
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

        let(:delegation_params) do
          { delegation: { granter_id: granter.id, grantee_id: grantee.id, decidim_action_delegator_setting_id: setting.id } }
        end

        before { create(:setting) }

        it "authorizes the action" do
          expect(controller).to receive(:allowed_to?).with(:create, :delegation, {})

          post :create, params: delegation_params
        end

        context "when successful" do
          it "creates a delegation" do
            expect { post :create, params: delegation_params }.to change(Delegation, :count).by(1)
          end
        end

        context "when failed" do
          it "shows an error" do
            post :create, params: { delegation: { granter_id: granter.id } }

            expect(response).to redirect_to(delegations_path)
            expect(flash[:error]).to eq(I18n.t("decidim.action_delegator.admin.delegations.create.error"))
          end
        end
      end

      describe "#destroy" do
        it "authorizes the action" do
          expect(controller).to receive(:allowed_to?).with(:destroy, :delegation, resource: delegation)

          delete :destroy, params: { id: delegation.id }
        end

        context "when the specified delegation does not belong to the current organization" do
          let(:consultation) { create(:consultation) }
          let(:setting) { create(:setting, consultation: consultation) }
          let(:delegation) { create(:delegation) }

          it "does destroy the delegation" do
            expect { delete :destroy, params: { id: delegation.id } }
              .not_to change(Delegation, :count)
          end
        end

        context "when successful" do
          it "destroys the specified delegation" do
            expect { delete :destroy, params: { id: delegation.id } }
              .to change(Delegation, :count).by(-1)

            expect(response).to redirect_to(setting_delegations_path(setting.id))
            expect(flash[:notice]).to eq(I18n.t("decidim.action_delegator.admin.delegations.destroy.success"))
          end
        end

        context "when failed" do
          before do
            allow_any_instance_of(Delegation).to receive(:destroy).and_return(false) # rubocop:disable RSpec/AnyInstance
          end

          it "shows an error" do
            delete :destroy, params: { id: delegation.id }

            expect(response).to redirect_to(setting_delegations_path(setting.id))
            expect(flash[:error]).to eq(I18n.t("decidim.action_delegator.admin.delegations.destroy.error"))
          end
        end
      end
    end
  end
end
