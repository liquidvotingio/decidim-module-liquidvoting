# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Admin
      class DelegationPresenter < SimpleDelegator
        def consultation
          Admin::ConsultationPresenter.new(__getobj__.consultation)
        end
      end
    end
  end
end
