# frozen_string_literal: true

module Decidim
  module Liquidvoting
    module Admin
      class ConsultationPresenter < SimpleDelegator
        include Decidim::TranslationsHelper

        def translated_title
          @translated_title ||= translated_attribute(title)
        end
      end
    end
  end
end
