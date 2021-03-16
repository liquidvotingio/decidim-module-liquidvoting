# frozen_string_literal: true

require "vcr"
require "byebug"

module LiquidvotingApiVcr
  def self.liquidvoting_api_uri?(uri)
    uri.hostname == liquidvoting_api_uri.hostname && uri.port == liquidvoting_api_uri.port
  end

  def self.liquidvoting_api_uri
    @liquidvoting_api_uri ||= URI(Decidim::Liquidvoting::Client::URL)
  end
end

VCR.configure do |config|
  config.default_cassette_options = { serialize_with: :json }
  config.cassette_library_dir = "spec/cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.ignore_request { |request| !LiquidvotingApiVcr.liquidvoting_api_uri?(URI(request.uri)) }
  # config.allow_http_connections_when_no_cassette = true
end
