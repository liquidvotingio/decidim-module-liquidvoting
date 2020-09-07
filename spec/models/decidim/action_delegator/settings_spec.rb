# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ActionDelegator
    describe Settings, type: :model do
      subject { build(:setting) }

      it { is_expected.to belong_to(:consultation) }
      it { is_expected.to have_many(:delegations).dependent(:destroy) }

      it { is_expected.to validate_presence_of(:max_grants) }
      it { is_expected.to validate_presence_of(:expires_at) }
      it { is_expected.to validate_numericality_of(:max_grants).is_greater_than(0) }

      context "when the expires_at is in the past" do
        subject { build(:setting, expires_at: Time.zone.now - 1.day) }

        it { is_expected.not_to be_valid }
      end

      context "when the expires_at is in the future" do
        it { is_expected.to be_valid }
      end
    end
  end
end
