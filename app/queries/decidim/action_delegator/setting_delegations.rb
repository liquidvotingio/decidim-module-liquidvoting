# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class SettingDelegations < Rectify::Query
      def initialize(setting)
        @setting = setting
      end

      def query
        Delegation.where(setting: setting)
      end

      private

      attr_reader :setting
    end
  end
end
