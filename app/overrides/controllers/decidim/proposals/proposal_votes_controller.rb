# frozen_string_literal: true

Decidim::Proposals::ProposalVotesController.class_eval do
  helper_method :api_state

  def create
    enforce_permission_to :vote, :proposal, proposal: proposal
    @from_proposals_list = params[:from_proposals_list] == "true"

    Decidim::Proposals::VoteProposal.call(proposal, current_user) do
      on(:ok) do
        proposal.reload

        proposals = Decidim::Proposals::ProposalVote.where(
          author: current_user,
          proposal: Decidim::Proposals::Proposal.where(component: current_component)
        ).map(&:proposal)

        refresh_from_api
        expose(proposals: proposals + [proposal], api_state: api_state)
        render :update_buttons_and_counters
      end

      on(:invalid) do
        render json: {
          error: I18n.t("proposal_votes.create.error", scope: "decidim.proposals")
        }, status: :unprocessable_entity
      end
    end
  end

  def destroy
    enforce_permission_to :unvote, :proposal, proposal: proposal
    @from_proposals_list = params[:from_proposals_list] == "true"

    Decidim::Proposals::UnvoteProposal.call(proposal, current_user) do
      on(:ok) do
        proposal.reload

        proposals = Decidim::Proposals::ProposalVote.where(
          author: current_user,
          proposal: Decidim::Proposals::Proposal.where(component: current_component)
        ).map(&:proposal)

        refresh_from_api
        expose(proposals: proposals + [proposal], api_state: api_state)
        render :update_buttons_and_counters
      end
    end
  end

  private

  attr_reader :api_state

  # Retrieve the current liquidvoting state. The state is exposed as a helper method :api_state.
  # Since timing with regard to votes and delegations is important, make this a deliberate act,
  # rather than a lazy memoized attribute.
  def refresh_from_api
    @api_state = Decidim::Liquidvoting.user_proposal_state(
      current_user&.email,
      Decidim::ResourceLocatorPresenter.new(proposal).url
    )
  end
end
