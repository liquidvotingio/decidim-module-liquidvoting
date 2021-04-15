# frozen_string_literal: true

require "spec_helper"

describe Decidim::Liquidvoting do
  subject { Decidim::Liquidvoting }

  describe "#create_vote" do
    let(:user) { create(:user) }
    let(:proposal) { create(:proposal) }

    it "forwards call to the api" do
      expect(Decidim::Liquidvoting::ApiClient).to receive(:create_vote).with(
        proposal_url: Decidim::ResourceLocatorPresenter.new(proposal).url, participant_email: user.email, yes: true
      )

      subject.create_vote(user.email, proposal)
    end

    it "updates the proposal count" do
      expect(proposal).to receive(:update_columns).with(proposal_votes_count: 1)

      subject.create_vote(user.email, proposal)
    end
  end

  describe "#delete_vote" do
    let(:user) { create(:user) }
    let(:proposal) { create(:proposal) }

    it "forwards call to the api" do
      expect(Decidim::Liquidvoting::ApiClient).to receive(:delete_vote).with(
        proposal_url: Decidim::ResourceLocatorPresenter.new(proposal).url, participant_email: user.email
      )

      subject.delete_vote(user.email, proposal)
    end

    it "updates the proposal count" do
      subject.create_vote(user.email, proposal)
      expect(proposal.proposal_votes_count).to eq(1)

      expect(proposal).to receive(:update_columns).with(proposal_votes_count: 0)

      subject.delete_vote(user.email, proposal)
    end
  end

  describe "#create_delegation" do
    let(:delegator) { create(:user) }
    let(:delegate) { create(:user) }
    let(:proposal) { create(:proposal) }

    it "forwards call to the api" do
      expect(Decidim::Liquidvoting::ApiClient).to receive(:create_delegation).with(
        proposal_url: Decidim::ResourceLocatorPresenter.new(proposal).url, delegator_email: delegator.email, delegate_email: delegate.email
      )

      subject.create_delegation(delegator.email, delegate.email, proposal)
    end

    it "updates the proposal count" do
      subject.create_vote(delegate.email, proposal)

      expected_count = 2 # the delegate, who has voted, and the delegator, who is delegating to them
      expect(proposal).to receive(:update_columns).with(proposal_votes_count: expected_count)

      subject.create_delegation(delegator.email, delegate.email, proposal)
    end
  end

  describe "#delete_delegation" do
    let(:delegator) { create(:user) }
    let(:delegate) { create(:user) }
    let(:proposal) { create(:proposal) }

    it "forwards call to the api" do
      expect(Decidim::Liquidvoting::ApiClient).to receive(:delete_delegation).with(
        proposal_url: Decidim::ResourceLocatorPresenter.new(proposal).url, delegator_email: delegator.email, delegate_email: delegate.email
      )

      subject.delete_delegation(delegator.email, delegate.email, proposal)
    end

    it "updates the proposal count" do
      subject.create_delegation(delegator.email, delegate.email, proposal)
      subject.create_vote(delegate.email, proposal)
      expect(proposal.proposal_votes_count).to eq(2)

      expected_count = 1 # only the delegate, who has voted; the delegation should be gone
      expect(proposal).to receive(:update_columns).with(proposal_votes_count: expected_count)

      subject.delete_delegation(delegator.email, delegate.email, proposal)
    end
  end

  describe "#user_proposal_state" do
    let(:user) { create(:user) }
    let(:delegate) { create(:user) }

    before do
      # stub API
      allow(Decidim::Liquidvoting::ApiClient).to receive(:fetch_user_voted?).and_return(true)
      allow(Decidim::Liquidvoting::ApiClient).to receive(:fetch_delegate_email).and_return(delegate.email)
    end

    it "includes :user_has_supported" do
      api_state = Decidim::Liquidvoting.user_proposal_state(user.email, "https://url_1")

      expect(api_state.user_has_supported).to be(true)
    end

    it "includes :delegate_id" do
      api_state = Decidim::Liquidvoting.user_proposal_state(user.email, "https://url_1")

      expect(api_state.delegate_id).to eq(delegate.id)
    end
  end

  describe "Logging" do
    let(:user) { create(:user) }
    let(:proposal) { create(:proposal) }
    let(:expected_msg) { /TRACE: Liquidvoting.update_votes_count set [0-9]+ for proposal id=#{proposal.id}/ }

    it "logs updates to the vote count" do
      expect(Decidim::Liquidvoting::Logger).to receive(:info).with(expected_msg)

      subject.create_vote(user.email, proposal)
    end
  end
end
