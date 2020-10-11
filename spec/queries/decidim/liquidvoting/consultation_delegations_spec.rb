# frozen_string_literal: true

require "spec_helper"

describe Decidim::ActionDelegator::ConsultationDelegations do
  subject { described_class.new(consultation, user) }

  let(:consultation) { create(:consultation) }
  let(:user) { create(:user) }
  let(:setting) { create(:setting, consultation: consultation) }

  let!(:consultation_delegation) { create(:delegation, setting: setting, grantee: user) }
  let!(:organization_delegation) { create(:delegation, grantee: user) }
  let!(:other_user_delegation) { create(:delegation, setting: setting) }

  describe "#query" do
    it "returns delegations of the specified consultation only" do
      expect(subject.query).to match_array([consultation_delegation])
    end
  end
end
