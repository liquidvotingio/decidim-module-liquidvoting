# frozen_string_literal: true

Decidim::Proposals::ProposalsController.class_eval do
  helper_method :api_state

  def index
    refresh_from_api

    if component_settings.participatory_texts_enabled?
      @proposals = Decidim::Proposals::Proposal
                   .where(component: current_component)
                   .published
                   .not_hidden
                   .only_amendables
                   .includes(:category, :scope)
                   .order(position: :asc)
      render "decidim/proposals/proposals/participatory_texts/participatory_text"
    else
      @base_query = search
                    .results
                    .published
                    .not_hidden

      @proposals = @base_query.includes(:component, :coauthorships)
      @all_geocoded_proposals = @base_query.geocoded

      @proposals = paginate(@proposals)
      @proposals = reorder(@proposals)
    end
  end

  def show
    raise ActionController::RoutingError, "Not Found" if @proposal.blank? || !can_show_proposal?

    refresh_from_api
  end

  def new
    enforce_permission_to :create, :proposal
    @step = :step_1
    if proposal_draft.present?
      redirect_to edit_draft_proposal_path(
        proposal_draft,
        component_id: proposal_draft.component.id,
        question_slug: proposal_draft.component.participatory_space.slug
      )
    else
      @form = form(ProposalWizardCreateStepForm).from_params(body: translated_proposal_body_template)
    end
  end

  private

  attr_reader :api_state

  # Retrieve the current liquidvoting state. The state is exposed via the helper method :api_state.
  #
  # Since timing with regard to votes and delegations is important, we make this a deliberate act,
  # rather than a lazy memoized attribute.
  #
  # This refresh is generally specific to a proposal, but if a proposal is not available, we request
  # api_state that is not proposal-specific
  def refresh_from_api
    @api_state =
      if @proposal
        proposal_url = Decidim::ResourceLocatorPresenter.new(@proposal).url

        Decidim::Liquidvoting.user_proposal_state(current_user&.email, proposal_url)
      else
        Decidim::Liquidvoting.user_proposal_state(current_user&.email)
      end
  end
end
