# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::Proposal do
  subject { create(:proposal) }

  it { is_expected.to be_valid }

  describe "#update_votes_count (LV extending Decidim method)" do
    context "when something updates the vote count attribute" do
      let(:votes_in_proposal_votes) { 3 }

      before do
        create_list(:proposal_vote, votes_in_proposal_votes, proposal: subject)
      end

      it "logs the unexpected call" do
        expect(Decidim::Liquidvoting::Logger).to receive(:info).with(/TRACE: Surprise/)

        subject.update_votes_count
      end

      it "is updated" do
        # subject.update_votes_count unneeded, because it's done in ProposalVote :after_save
        expect(subject.proposal_votes_count).to eq(votes_in_proposal_votes)
      end
    end
  end
end
