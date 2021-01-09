# frozen_string_literal: true

require "graphql/client"
require "graphql/client/http"

module Decidim
  module Liquidvoting
    # Copied over from https://github.com/liquidvotingio/ruby-client/blob/master/liquid_voting_api.rb.
    # Changes here will be applied there as well. Doing this for development speed, until
    # basics are ironed out and we can we publish the client as a gem.

    # This client integrates with the liquidvoting.io api, allowing for delegative voting
    # in a participatory space proposal.
    module Client
      URL = ENV.fetch("LIQUID_VOTING_API_URL", "http://localhost:4000")
      # URL = ENV.fetch('LIQUID_VOTING_API_URL', 'https://api.liquidvoting.io')
      AUTH_KEY = ENV.fetch("LIQUID_VOTING_API_AUTH_KEY", "62309201-d2f0-407f-875b-9f836f94f2ca")

      HTTP = ::GraphQL::Client::HTTP.new(URL) do
        def headers(_context)
          {
            "Authorization": "Bearer #{AUTH_KEY}",
            "Org-ID": "62309201-d2f0-407f-875b-9f836f94f2ca"
          }
        end
      end

      SCHEMA = ::GraphQL::Client.load_schema(HTTP)
      CLIENT = ::GraphQL::Client.new(schema: SCHEMA, execute: HTTP)



      # TODO: Edit comments to reflect new def.

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
      VotingResultQuery = CLIENT.parse <<-GRAPHQL
      query($proposal_url: String!) {
        votingResult(proposalUrl: $proposal_url) {
          inFavor
        }
      }

      GRAPHQL

      def self.voting_result(proposal_url)
      variables = { proposal_url: proposal_url }
      response = send_query(VotingResultQuery, variables: variables)

      return response.data.voting_result.in_favor unless response.data.errors.any?

      raise response.data.errors.messages["votingResult"].join(", ")
      end




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

        return response.data.create_vote unless response.data.errors.any?

        raise response.data.errors.messages["createVote"].join(", ")
      end

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

      def self.delete_vote(proposal_url:, participant_email:)
        variables = { proposal_url: proposal_url, participant_email: participant_email }
        response = send_query(DeleteVoteMutation, variables: variables)

        return response.data.delete_vote unless response.data.errors.any?

        raise response.data.errors.messages["deleteVote"].join(", ")
      end

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

      def self.votes
        response = send_query(VotesQuery)

        return response.data.votes unless response.data.errors.any?

        raise response.data.errors.messages["votes"].join(", ")
      end

      # return exactly one vote from participant_email for proposal_url, or nil
      def self.vote_for(participant_email, proposal_url)
        # this is a hack until we can properly query a subset of delegations
        votes.find do |v|
          v.participant.email == participant_email && v.proposal_url == proposal_url
        end
      end

      CreateDelegationMutation = CLIENT.parse <<-GRAPHQL
        mutation($proposal_url: String!, $delegator_email: String!, $delegate_email: String!) {
          createDelegation(proposalUrl: $proposal_url, delegatorEmail: $delegator_email, delegateEmail: $delegate_email) {
            id
          }
        }

      GRAPHQL

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

        return true unless response.data.errors.any?

        raise response.data.errors.messages["createDelegation"].join(", ")
      end

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

        return response.data.delete_delegation unless response.data.errors.any?

        raise response.data.errors.messages["deleteDelegation"].join(", ")
      end

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

      def self.delegations
        response = send_query(DelegationsQuery)

        return response.data.delegations unless response.data.errors.any?

        raise response.data.errors.messages["delegations"].join(", ")
      end

      # return exactly one delegation from delegator_email for proposal_url, or nil
      def self.delegation_for(delegator_email, proposal_url)
        # this is a hack until we can properly query a subset of delegations
        delegations.find do |d|
          d.delegator.email == delegator_email && d.proposal_url == proposal_url
        end
      end

      ## A wrapper for all LiquidVoting calls
      def self.send_query(query, variables: {})
        Rails.logger.info "Liquidvoting request sent: #{query.inspect} #{variables.inspect}"
        CLIENT.query(query, variables: variables)
      end
    end
  end
end
