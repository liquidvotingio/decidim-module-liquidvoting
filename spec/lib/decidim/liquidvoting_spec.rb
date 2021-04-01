# frozen_string_literal: true

require "spec_helper"

describe Decidim::Liquidvoting do
  subject { Decidim::Liquidvoting }

  describe "#update_votes_count" do
    let(:proposal) { create(:proposal) }
    let(:new_vote_count) { 35 }
    let(:expected_msg) { "TRACE: Liquidvoting.update_votes_count set #{new_vote_count} for proposal id=#{proposal.id}" }

    it "logs the unexpected call" do
      expect(Decidim::Liquidvoting::Logger).to receive(:info).with(expected_msg)

      subject.update_votes_count(proposal, new_vote_count)
    end
  end

  describe "#user_proposal_state" do
    let(:user) { create(:user, :confirmed) }

    it "includes :user_has_supported" do
      allow(Decidim::Liquidvoting::ApiClient).to receive(:fetch_user_supported).and_return(true)

      lv_state = Decidim::Liquidvoting.user_proposal_state(user.email, "https://url_1")

      expect(lv_state.user_has_supported).to be(true)
    end
  end
end
