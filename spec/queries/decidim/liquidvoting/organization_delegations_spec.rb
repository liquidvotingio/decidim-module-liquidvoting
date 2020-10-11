# frozen_string_literal: true

require "spec_helper"

describe Decidim::ActionDelegator::OrganizationDelegations do
  subject { described_class.new(organization) }

  let(:organization) { create(:organization) }
  let(:consultation) { create(:consultation, organization: organization) }
  let(:setting) { create(:setting, consultation: consultation) }
  let!(:delegation) { create(:delegation, setting: setting) }

  let!(:other_delegation) { create(:delegation) }

  describe "#query" do
    it "returns delegations of the specified organization only" do
      expect(subject.query).to match_array([delegation])
    end
  end
end
