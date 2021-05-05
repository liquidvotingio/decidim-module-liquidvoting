# frozen_string_literal: true

require "graphql/client"
require "graphql/client/http"

module Decidim
  module Liquidvoting
    # Copied over from https://github.com/liquidvotingio/api-client/blob/master/liquid_voting_api.rb.
    # Changes here will be applied there as well. Doing this for now for development speed, until
    # basics are ironed out and we can we publish the client as a gem.

    # This client integrates with the liquidvoting.io api, allowing for delegative voting
    # in a participatory space proposal.
    module ApiClient
      # Default ENV vars configuring use of the live API with an AUTH_KEY for a demo organization.
      #
      # This default config works: the demo organization exists on the live API so one can easily test drive it.
      #
      # Deploying the liquidvoting API locally or within a private network works differently. Requests won't
      # go through the live auth service, which would have exchanged the AUTH_KEY for an ORG_ID, so
      # an AUTH_KEY isn't needed and an ORG_ID can be sent directly.
      #
      # Example:
      #
      # LIQUID_VOTING_API_URL = "http://localhost:4000"
      # LIQUID_VOTING_API_ORG_ID = "24e173f5-d99a-4470-b1cc-142b392df10a"
      #
      URL = ENV.fetch("LIQUID_VOTING_API_URL", "https://api.liquidvoting.io")
      AUTH_KEY = ENV.fetch("LIQUID_VOTING_API_AUTH_KEY", "62309201-d2f0-407f-875b-9f836f94f2ca")
      ORG_ID = ENV.fetch("LIQUID_VOTING_API_ORG_ID", "")

      HTTP = ::GraphQL::Client::HTTP.new(URL) do
        def headers(_context)
          {
            "Authorization": "Bearer #{AUTH_KEY}",
            "Org-ID": ORG_ID
          }
        end
      end

      SCHEMA = ::GraphQL::Client.load_schema(HTTP)
      CLIENT = ::GraphQL::Client.new(schema: SCHEMA, execute: HTTP)

      def self.fetch_user_voted?(user_email, proposal_url)
        user_voted?(user_email, proposal_url)
      end

      def self.fetch_delegate_email(user_email, proposal_url)
        delegate_email_for(user_email, proposal_url)
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

        response.data.create_delegation
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

      ## private class methods

      ## A logging wrapper for all Liquidvoting api calls
      private_class_method def self.send_query(query, variables: {})
        Rails.logger.info "Liquidvoting request sent: #{query.inspect} #{variables.inspect}"
        CLIENT.query(query, variables: variables)
      end

      # This method is a hack until we can properly query a subset of votes;
      # it currently retrieves ALL votes in LV and then filters!
      private_class_method def self.user_voted?(participant_email, proposal_url)
        return false unless participant_email.present? && proposal_url.present?

        api_response = send_query(VotesQuery)
        raise api_response.data.errors.messages["votes"].join(", ") if api_response.data.errors.any?

        vote = api_response.data.votes.find do |v|
          v.participant.email == participant_email && v.proposal_url == proposal_url
        end

        !!vote
      end

      # This method is a hack until we can properly query a subset of delegations;
      # it currently retrieves ALL delegations in LV and then filters!
      private_class_method def self.delegate_email_for(delegator_email, proposal_url)
        return unless delegator_email.present? && proposal_url.present?

        api_response = send_query(DelegationsQuery)
        raise api_response.data.errors.messages["delegations"].join(", ") if api_response.data.errors.any?

        delegation = api_response.data.delegations.find do |d|
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
            votingResult {
              inFavor
              against
            }
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
