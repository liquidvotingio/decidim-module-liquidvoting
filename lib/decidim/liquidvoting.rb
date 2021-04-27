# frozen_string_literal: true

require "decidim/liquidvoting/engine"
require "decidim/liquidvoting/api_client"
require "decidim/liquidvoting/logger"

module Decidim
  # This namespace holds the logic of the `Liquidvoting` module
  module Liquidvoting
    def self.create_vote(voter_email, proposal)
      response = Decidim::Liquidvoting::ApiClient.create_vote(
        proposal_url: ResourceLocatorPresenter.new(proposal).url,
        participant_email: voter_email,
        yes: true
      )
      new_count = response&.voting_result&.in_favor

      update_votes_count(proposal, new_count) if new_count
    end

    def self.delete_vote(voter_email, proposal)
      response = Decidim::Liquidvoting::ApiClient.delete_vote(
        proposal_url: ResourceLocatorPresenter.new(proposal).url,
        participant_email: voter_email
      )
      new_count = response&.voting_result&.in_favor

      update_votes_count(proposal, new_count) if new_count
    end

    def self.create_delegation(delegator_email, delegate_email, proposal)
      response = Decidim::Liquidvoting::ApiClient.create_delegation(
        proposal_url: ResourceLocatorPresenter.new(proposal).url,
        delegator_email: delegator_email,
        delegate_email: delegate_email
      )
      new_count = response&.voting_result&.in_favor

      update_votes_count(proposal, new_count) if new_count
    end

    def self.delete_delegation(delegator_email, delegate_email, proposal)
      response = Decidim::Liquidvoting::ApiClient.delete_delegation(
        proposal_url: ResourceLocatorPresenter.new(proposal).url,
        delegator_email: delegator_email,
        delegate_email: delegate_email
      )
      new_count = response&.voting_result&.in_favor

      update_votes_count(proposal, new_count) if new_count
    end

    UserProposalState = Struct.new(:user_has_supported, :delegate_id)

    # Gather all relevant LV api state, based on the current user's email and the url of a proposal.
    #
    # There are some contexts like ProposalsController#index which are not specific to a specific proposal.
    # For these cases, proposal_url is optional, and an empty UserProposalState is returned so
    # views can query the api_state object.
    #
    # Proposals in this case are expected to be unvoted and undelegated: views like ProposalsController#index
    # should not expose vote/delegate status unless it's unvoted/undelegated.
    def self.user_proposal_state(user_email, proposal_url = nil)
      return UserProposalState.new unless proposal_url

      user_has_supported = Decidim::Liquidvoting::ApiClient.fetch_user_voted?(user_email, proposal_url)
      delegate_email = Decidim::Liquidvoting::ApiClient.fetch_delegate_email(user_email, proposal_url)

      delegate_id = Decidim::User.find_by(email: delegate_email)&.id if delegate_email.present?

      UserProposalState.new(user_has_supported, delegate_id)
    end

    # rubocop:disable Rails/SkipsModelValidations
    private_class_method def self.update_votes_count(proposal, new_count)
      proposal.update_columns(proposal_votes_count: new_count)

      msg = "TRACE: Liquidvoting.update_votes_count set #{new_count.inspect} for proposal id=#{proposal.id}"
      Decidim::Liquidvoting::Logger.info msg
    end
    # rubocop:enable Rails/SkipsModelValidations
  end
end

# User space engine, generally used in the context of proposal voting to let users
# manage their delegations
Decidim.register_global_engine(
  :liquidvoting, # this is the name of the global method to access engine routes
  Decidim::Liquidvoting::Engine,
  at: "/"
)
