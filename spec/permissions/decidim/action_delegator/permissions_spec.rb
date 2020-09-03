# frozen_string_literal: true

require "spec_helper"

describe Decidim::ActionDelegator::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { build(:user, :admin) }
  let(:permission_action) { Decidim::PermissionAction.new(action) }
  let(:context) { {} }

  context "when scope is not admin" do
    context "when listing delegations" do
      let(:action) do
        { scope: :public, action: :index, subject: :delegation }
      end

      it_behaves_like "permission is not set"
    end

    context "when listing settings" do
      let(:action) do
        { scope: :public, action: :index, subject: :setting }
      end

      it_behaves_like "permission is not set"
    end
  end

  context "when scope is admin" do
    let(:scope) { :admin }

    context "when subject is not delegation or setting" do
      let(:action) do
        { scope: scope, action: :index, subject: :other }
      end

      it_behaves_like "permission is not set"
    end

    context "when listing delegations" do
      let(:action) do
        { scope: scope, action: :index, subject: :delegation }
      end

      context "when the user is admin" do
        it { is_expected.to eq(true) }
      end

      context "when the user is not admin" do
        let(:user) { build(:user) }

        it_behaves_like "permission is not set"
      end
    end

    context "when creating a delegation" do
      let(:action) do
        { scope: scope, action: :create, subject: :delegation }
      end

      context "when the user is admin" do
        it { is_expected.to eq(true) }
      end

      context "when the user is not admin" do
        let(:user) { build(:user) }

        it_behaves_like "permission is not set"
      end
    end

    context "when destroying a delegation" do
      let(:action) do
        { scope: scope, action: :destroy, subject: :delegation }
      end
      let(:context) { { resource: create(:delegation) } }

      context "when the user is admin" do
        it { is_expected.to eq(true) }
      end

      context "when the user is not admin" do
        let(:user) { build(:user) }

        it_behaves_like "permission is not set"
      end
    end

    context "when listing settings" do
      let(:action) do
        { scope: scope, action: :index, subject: :setting }
      end

      context "when the user is admin" do
        it { is_expected.to eq(true) }
      end

      context "when the user is not admin" do
        let(:user) { build(:user) }

        it_behaves_like "permission is not set"
      end
    end

    context "when creating a setting" do
      let(:action) do
        { scope: scope, action: :create, subject: :setting }
      end

      context "when the user is admin" do
        it { is_expected.to eq(true) }
      end

      context "when the user is not admin" do
        let(:user) { build(:user) }

        it_behaves_like "permission is not set"
      end
    end

    context "when destroying a setting" do
      let(:action) do
        { scope: scope, action: :destroy, subject: :setting }
      end
      let(:context) { { resource: create(:setting) } }

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
