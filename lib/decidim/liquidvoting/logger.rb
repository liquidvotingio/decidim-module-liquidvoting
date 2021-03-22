# frozen_string_literal: true

module Decidim
  module Liquidvoting
    module Logger
      def self.info(msg)
        Rails.logger.info msg
      end
    end
  end
end
