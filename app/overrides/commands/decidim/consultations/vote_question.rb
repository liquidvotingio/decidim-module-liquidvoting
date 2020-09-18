# frozen_string_literal: true

Decidim::Consultations::VoteQuestion.class_eval do
  private

  def build_vote
    author = delegation ? delegation.granter : form.context.current_user
    form.context.current_question.votes.build(
      author: author,
      response: form.response
    )
  end

  def delegation
    @delegation ||= Decidim::ActionDelegator::ConsultationDelegations.for(
      current_question.consultation,
      form.context.current_user
    ).find_by(id: form.decidim_consultations_delegation_id)
  end
end
