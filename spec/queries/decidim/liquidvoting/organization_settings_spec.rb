# frozen_string_literal: true

require "spec_helper"

describe Decidim::ActionDelegator::OrganizationSettings do
  subject { described_class.new(organization) }

  let(:organization) { create(:organization) }
  let(:consultation) { create(:consultation, organization: organization) }
  let!(:setting) { create(:setting, consultation: consultation) }

  let!(:other_setting) { create(:setting) }

  describe "#query" do
    it "returns settings of the specified organization only" do
      expect(subject.query).to match_array([setting])
    end
  end
end
