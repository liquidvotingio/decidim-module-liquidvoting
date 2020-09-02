# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ActionDelegator
    describe Delegation, type: :model do
      subject { build(:delegation) }

      it { is_expected.to belong_to(:setting) }
      it { is_expected.to be_valid }
    end
  end
end
