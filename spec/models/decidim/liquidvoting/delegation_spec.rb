# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Liquidvoting
    describe Delegation, type: :model do
      subject { build(:delegation) }

      it { is_expected.to belong_to(:setting) }
      it { is_expected.to be_valid }

      describe ".granted_to?" do
        let(:user) { create(:user) }
        let(:organization) { create(:organization) }
        let(:consultation) { create(:consultation, :active, organization: organization) }
        let(:setting) { create(:setting, consultation: consultation) }

        context "when there is no delegation granted to user for the given consultation" do
          it "returns false" do
            expect(described_class.granted_to?(user, consultation)).to eq(false)
          end
        end

        context "when there are delegations granted to user for the given consultation" do
          let!(:delegation) { create(:delegation, setting: setting, grantee: user) }

          it "returns true" do
            expect(described_class.granted_to?(user, consultation)).to eq(true)
          end
        end
      end
    end
  end
end
