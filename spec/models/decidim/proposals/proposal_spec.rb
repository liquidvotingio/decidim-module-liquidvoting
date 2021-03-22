# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::Proposal do
  subject { create(:proposal) }

  it { is_expected.to be_valid }

  describe "#update_votes_count (no-op stubbed Decidim method)" do
    it "logs the unexpected call" do
      expect(Decidim::Liquidvoting::Logger).to receive(:info).with(/TRACE: Surprise/)

      subject.update_votes_count
    end
  end

  describe "#update_with_lv_vote_count" do
    let(:new_vote_count) { 35 }

    context "when we update the vote count" do
      before do
        subject.update_with_lv_vote_count(new_vote_count)
        subject.reload
      end

      it "is updated" do
        expect(subject.proposal_votes_count).to eq(new_vote_count)
      end

      it "is independent of the :votes association" do
        expect(subject.votes.count).to eq(0)
      end

      it "logs the call" do
        expect(Decidim::Liquidvoting::Logger).to receive(:info).with(/TRACE: Liquidvoting set/)

        subject.update_with_lv_vote_count(new_vote_count)
      end
    end
  end
end
