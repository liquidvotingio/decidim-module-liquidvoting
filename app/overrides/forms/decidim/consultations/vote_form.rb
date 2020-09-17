# frozen_string_literal: true

Decidim::Consultations::VoteForm.class_eval do
  attribute :decidim_consultations_delegation_id, Integer
end
