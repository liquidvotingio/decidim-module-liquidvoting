# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::Proposal do
  subject { create(:proposal) }

  it { is_expected.to be_valid }

  describe "#update_votes_count" do
    let(:new_vote_count) { 35 }

    context "when we update the vote count" do
      before do
        subject.update_votes_count(new_vote_count)
        subject.reload
      end

      it "is updated" do
        expect(subject.proposal_votes_count).to eq(new_vote_count)
      end

      it "is independent of the :votes association" do
        expect(subject.votes.count).to eq(0)
      end
    end

    context "when called without an argument from non-liquidvoting code" do
      before do
        subject.update_votes_count(new_vote_count)
        subject.reload
      end

      it "can be called without argument" do
        expect { subject.update_votes_count }.not_to raise_error(ArgumentError)
      end

      it "is a no-op when called without argument" do
        subject.update_votes_count

        expect(subject.proposal_votes_count).to eq(new_vote_count)
      end
    end
  end
end
