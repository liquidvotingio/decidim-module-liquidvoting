# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Admin
      class SettingPresenter < SimpleDelegator
        def consultation
          Admin::ConsultationPresenter.new(__getobj__.consultation)
        end
      end
    end
  end
end
