# frozen_string_literal: true

require "spec_helper"

describe Decidim::ActionDelegator::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { build(:user, :admin) }
  let(:permission_action) { Decidim::PermissionAction.new(action) }
  let(:context) { {} }

  let(:delegation) { build(:delegation, granter: user) }

  context "when scope is not admin" do
    let(:action) do
      { scope: :public, action: :index, subject: :delegation }
    end

    it_behaves_like "permission is not set"
  end

  context "when scope is admin" do
    let(:scope) { { scope: :admin } }

    context "when subject is not delegation" do
      let(:action) do
        { scope: :admin, action: :index, subject: :other }
      end

      it_behaves_like "permission is not set"
    end

    context "when listing delegations" do
      let(:action) do
        { scope: :admin, action: :index, subject: :delegation }
      end

      context "when the user is admin" do
        it { is_expected.to eq(true) }
      end

      context "when the user is not admin" do
        let(:user) { build(:user) }

        it_behaves_like "permission is not set"
      end
    end

    context "when destorying a delegation" do
      let(:action) do
        { scope: :admin, action: :destroy, subject: :delegation }
      end

      context "when the user is admin" do
        it { is_expected.to eq(true) }
      end

      context "when the user is not admin" do
        let(:user) { build(:user) }

        it_behaves_like "permission is not set"
      end
    end
  end
end
