# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ActionDelegator
    describe Admin::DelegationsController, type: :controller do
      routes { Decidim::ActionDelegator::AdminEngine.routes }

      let(:organization) { create(:organization) }
      let(:consultation) { create(:consultation, organization: organization) }
      let(:user) { create(:user, :admin, :confirmed, organization: organization) }

      let!(:delegation) { create(:delegation, consultation: consultation) }

      before do
        request.env["decidim.current_organization"] = organization
        sign_in user
      end

      describe "#index" do
        it "authorizes the action" do
          expect(controller.allowed_to?(:index, :delegation)).to eq true

          get :index
        end

        it "renders the index template" do
          get :index

          expect(response).to render_template(:index)
          expect(response).to have_http_status(:ok)
        end

        context "with view rendering" do
          render_views

          it "lists delegations of the current organization" do
            non_org_delegation = create(:delegation)

            get :index

            expect(response.body).to include(delegation_path(delegation))
            expect(response.body).not_to include(delegation_path(non_org_delegation))
          end
        end
      end

      describe "#create" do
        let(:granter) { create(:user, organization: organization) }
        let(:grantee) { create(:user, organization: organization) }
        let(:consultation) { create(:consultation, organization: organization) }

        let(:delegation_params) do
          { delegation: { granter_id: granter.id, grantee_id: grantee.id, decidim_consultation_id: consultation.id } }
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
          expect(controller).to receive(:allowed_to?).with(:destroy, :delegation, {})

          delete :destroy, params: { id: delegation.id }
        end

        context "when successful" do
          it "destroys the specified delegation" do
            expect { delete :destroy, params: { id: delegation.id } }
              .to change(Delegation, :count).by(-1)

            expect(response).to redirect_to(delegations_path)
            expect(flash[:notice]).to eq(I18n.t("decidim.action_delegator.admin.delegations.destroy.success"))
          end
        end

        context "when failed" do
          before do
            allow(delegation).to receive(:destroy).and_return(false)
            allow(Delegation).to receive(:find_by).with(id: delegation.id.to_s).and_return(delegation)
          end

          it "shows an error" do
            delete :destroy, params: { id: delegation.id }

            expect(response).to redirect_to(delegations_path)
            expect(flash[:error]).to eq(I18n.t("decidim.action_delegator.admin.delegations.destroy.error"))
          end
        end
      end
    end
  end
end
