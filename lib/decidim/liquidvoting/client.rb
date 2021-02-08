# frozen_string_literal: true

require "graphql/client"
require "graphql/client/http"

module Decidim
  module Liquidvoting

    ProposalState = Struct.new(:user_has_voted, :delegate_email)

    # Copied over from https://github.com/liquidvotingio/ruby-client/blob/master/liquid_voting_api.rb.
    # Changes here will be applied there as well. Doing this for development speed, until
    # basics are ironed out and we can we publish the client as a gem.

    # This client integrates with the liquidvoting.io api, allowing for delegative voting
    # in a participatory space proposal.
    module Client
      URL = ENV.fetch("LIQUID_VOTING_API_URL", "http://localhost:4000")
      # URL = ENV.fetch('LIQUID_VOTING_API_URL', 'https://api.liquidvoting.io')
      AUTH_KEY = ENV.fetch("LIQUID_VOTING_API_AUTH_KEY", "62309201-d2f0-407f-875b-9f836f94f2ca")
      ORG_ID = ENV.fetch("LIQUID_VOTING_API_ORG_ID", "62309201-d2f0-407f-875b-9f836f94f2ca")

      HTTP = ::GraphQL::Client::HTTP.new(URL) do
        def headers(_context)
          {
            "Authorization": "Bearer #{AUTH_KEY}",
            "Org-ID": "#{ORG_ID}"
          }
        end
      end

      SCHEMA = ::GraphQL::Client.load_schema(HTTP)
      CLIENT = ::GraphQL::Client.new(schema: SCHEMA, execute: HTTP)


      ## Return a snapshot of current Liquidvoting state for the given user and proposal.
      ##
      ## The intent is to encapsulate all of the LV state relevant to a user and a specific proposal
      ## in a single LV state object, to give controllers a simple way to acquire that object, and
      ## to make that state available throughout the duration of the web request.
      ##
      ## As a ruby Struct, the object is immutable; the best way to refresh the state is to
      ## reacquire this state object.
      def self.current_proposal_state(participant_email, proposal_url)
        # TODO: this is multiple calls to LV, maybe we can consolidate to a single graphql call
        user_has_voted = has_user_voted?(participant_email, proposal_url)
        delegate_email = delegate_email_for(participant_email, proposal_url)

        ProposalState.new(user_has_voted, delegate_email)
      end

      ## Example:
      ##
      ## create_vote(
      ##   yes: true,
      ##   proposal_url: "https://my.decidim.com/proposal",
      ##   participant_email: "alice@email.com"
      ## )
      ## => vote
      ## vote.yes => true
      ## vote.voting_result.yes => 1
      ## vote.voting_result.no => 0
      ##
      ## On failure it will raise an exception with the errors returned by the API
      def self.create_vote(yes:, proposal_url:, participant_email:)
        variables = { yes: yes, proposal_url: proposal_url, participant_email: participant_email }
        response = send_query(CreateVoteMutation, variables: variables)

        # TODO: CreateVoteMutation returns a different structure for errors than the three other api calls do
        raise response.data.errors.messages["createVote"].join(", ") if response.data.errors.any?

        response.data.create_vote
      end

      def self.delete_vote(proposal_url:, participant_email:)
        variables = { proposal_url: proposal_url, participant_email: participant_email }
        response = send_query(DeleteVoteMutation, variables: variables)

        raise response.errors.messages["data"].join(", ") if response.errors.any?

        response.data.delete_vote
      end

      ## Example:
      ##
      ## create_delegation(
      ##   proposal_url: "https://my.decidim.com/proposal",
      ##   delegator_email: "bob@email.com",
      ##   delegate_email: "alice@email.com"
      ## )
      ## => true
      ##
      ## On failure it will raise an exception with the errors returned by the API
      def self.create_delegation(proposal_url:, delegator_email:, delegate_email:)
        variables = {
          proposal_url: proposal_url,
          delegator_email: delegator_email,
          delegate_email: delegate_email
        }
        response = send_query(CreateDelegationMutation, variables: variables)

        raise response.errors.messages["data"].join(", ") if response.errors.any?

        # TODO: why do we return a boolean rather than a data.delete_delegation like other methods?
        true
      end

      ## Example:
      ##
      ## delete_delegation(
      ##   proposal_url: "https://my.decidim.com/proposal",
      ##   delegator_email: "bob@email.com",
      ##   delegate_email: "alice@email.com"
      ## )
      ## => deleted_delegation
      ## deleted_delegation.voting_result.yes => 0
      ## deleted_delegation.voting_result.no => 0
      ##
      ## On failure it will raise an exception with the errors returned by the API
      def self.delete_delegation(proposal_url:, delegator_email:, delegate_email:)
        variables = {
          proposal_url: proposal_url,
          delegator_email: delegator_email,
          delegate_email: delegate_email
        }
        response = send_query(DeleteDelegationMutation, variables: variables)

        raise response.errors.messages["data"].join(", ") if response.errors.any?

        response.data.delete_delegation
      end



      private

      ## A logging wrapper for all Liquidvoting api calls
      def self.send_query(query, variables: {})
        Rails.logger.info "Liquidvoting request sent: #{query.inspect} #{variables.inspect}"
        CLIENT.query(query, variables: variables)
      end

      def self.votes
        response = send_query(VotesQuery)

        raise response.data.errors.messages["votes"].join(", ") if response.data.errors.any?

        response.data.votes
      end

      def self.has_user_voted?(participant_email, proposal_url)
        participant_email.present? && proposal_url.present? or return false

        # this is a hack until we can properly query a subset of delegations
        vote = votes.find do |v|
          v.participant.email == participant_email && v.proposal_url == proposal_url
        end

        !!vote
      end

      def self.delegations
        response = send_query(DelegationsQuery)

        raise response.data.errors.messages["delegations"].join(", ") if response.data.errors.any?

        response.data.delegations
      end

       def self.delegate_email_for(delegator_email, proposal_url)
        delegator_email.present? && proposal_url.present? or return

        # this is a hack until we can properly query a subset of delegations
        delegation = delegations.find do |d|
          d.delegator.email == delegator_email && d.proposal_url == proposal_url
        end

        delegation&.delegate&.email
      end



     ## All graphql query definitions here:

      CreateVoteMutation = CLIENT.parse <<-GRAPHQL
        mutation($participant_email: String, $proposal_url: String!, $yes: Boolean!) {
          createVote(participantEmail: $participant_email, proposalUrl: $proposal_url, yes: $yes) {
            yes
            weight
            participant {
              email
            }
            votingResult {
              inFavor
              against
            }
          }
        }
      GRAPHQL

      DeleteVoteMutation = CLIENT.parse <<-GRAPHQL
        mutation($participant_email: String, $proposal_url: String!) {
          deleteVote(participantEmail: $participant_email, proposalUrl: $proposal_url) {
            participant {
              email
            }
            votingResult {
              inFavor
              against
            }
          }
        }
      GRAPHQL

      CreateDelegationMutation = CLIENT.parse <<-GRAPHQL
        mutation($proposal_url: String!, $delegator_email: String!, $delegate_email: String!) {
          createDelegation(proposalUrl: $proposal_url, delegatorEmail: $delegator_email, delegateEmail: $delegate_email) {
            id
          }
        }

      GRAPHQL

      DeleteDelegationMutation = CLIENT.parse <<-GRAPHQL
        mutation($proposal_url: String!, $delegator_email: String!, $delegate_email: String!) {
          deleteDelegation(proposalUrl: $proposal_url, delegatorEmail: $delegator_email, delegateEmail: $delegate_email) {
            votingResult {
              inFavor
              against
            }
          }
        }

      GRAPHQL

      ## Example:
      ##
      ## votingResult(proposal_url: "https://my.decidim.com/proposal")
      ## => votingResult
      ##    => inFavor => 17
      ##
      ## On failure it will raise an exception with the errors returned by the API
      VotingResultQuery = CLIENT.parse <<-GRAPHQL
      query($proposal_url: String!) {
        votingResult(proposalUrl: $proposal_url) {
          inFavor
        }
      }

      GRAPHQL

      ## Example:
      ##
      ## votes()
      ## => votes
      ##    => "https://proposals.com/proposal1"
      ##    => participant
      ##        => email => john@gmail.com
      ##                 => ...
      VotesQuery = CLIENT.parse <<-GRAPHQL
      query {
        votes {
          proposalUrl
          participant {
            email
          }
        }
      }

      GRAPHQL

      ## Example:
      ##
      ## delegations()
      ## => delegations
      ##    => delegator
      ##        => email => john@gmail.com
      ##                 => ...
      ##    => delegate
      ##        => email => jane@gmail.com
      ##                 => ...
      DelegationsQuery = CLIENT.parse <<-GRAPHQL
        query {
          delegations {
            proposalUrl
            delegator {
              email
            }
            delegate {
              email
            }
          }
        }

      GRAPHQL

    end
  end
end
