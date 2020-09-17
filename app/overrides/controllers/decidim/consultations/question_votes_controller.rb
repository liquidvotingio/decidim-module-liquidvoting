# frozen_string_literal: true

Decidim::Consultations::QuestionVotesController.class_eval do
  def create
    enforce_permission_to :vote, :question, question: current_question

    vote_form = form(Decidim::ActionDelegator::VoteForm).from_params(params, current_question: current_question)
    VoteQuestion.call(vote_form) do
      on(:ok) do
        current_question.reload
        render :update_vote_button
      end

      on(:invalid) do
        render json: {
          error: I18n.t("question_votes.create.error", scope: "decidim.consultations")
        }, status: :unprocessable_entity
      end
    end
  end

  def destroy
    enforce_permission_to_unvote :question, question: current_question
    UnvoteQuestion.call(current_question, delegation.present? ? delegation.granter : current_user) do
      on(:ok) do
        current_question.reload
        render :update_vote_button
      end
    end
  end

  private

  def delegation
    @delegation ||= Decidim::ActionDelegator::Delegation.find_by(id: params[:decidim_consultations_delegation_id])
  end

  def enforce_permission_to_unvote(subject, extra_context = {})
    if delegation.blank?
      enforce_permission_to :unvote, :question, question: current_question
    else
      if Rails.env.development?
        Rails.logger.debug "==========="
        Rails.logger.debug [permission_scope, :unvote, subject, permission_class_chain].map(&:inspect).join("\n")
        Rails.logger.debug "==========="
      end

      raise Decidim::ActionForbidden unless allowed_to?(
        :unvote,
        subject,
        extra_context,
        [Decidim::Consultations::Permissions, Decidim::Admin::Permissions, Decidim::Permissions],
        delegation.granter
      )
    end
  end
end
