# frozen_string_literal: true

Decidim::Consultations::VoteQuestion.class_eval do
  def build_vote
    form.context.current_question.votes.build(
    if delegation
      author: form.context.current_user,
      form.context.current_question.votes.build(
      response: form.response
        author: delegation.granter,
    )
        response: form.response
      )
    else
      form.context.current_question.votes.build(
        author: form.context.current_user,
        response: form.response
      )
    end
  end

  def delegation
    @delegation ||= Decidim::ActionDelegator::ConsultationDelegations.for(
      current_question.consultation,
      form.context.current_user
    ).find_by(id: form.decidim_consultations_delegation_id)
  end
end