# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ActionDelegator
    module Admin
      describe Admin::DelegationsController, type: :controller do
        routes { Decidim::ActionDelegator::AdminEngine.routes }

        let(:organization) { create :organization }
        let(:user) { create(:user, :confirmed, organization: organization) }

        let!(:delegation) { create(:delegation) }

        before do
          request.env["decidim.current_organization"] = organization
          sign_in user
        end

        describe "#destroy" do
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

            it "shows the error" do
              delete :destroy, params: { id: delegation.id }

              expect(response).to redirect_to(delegations_path)
              expect(flash[:error]).to eq(I18n.t("decidim.action_delegator.admin.delegations.destroy.error"))
            end
          end
        end
      end
    end
  end
end
