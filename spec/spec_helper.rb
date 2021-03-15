# frozen_string_literal: true

require "decidim/dev"
require_relative 'support/vcr_setup'
require "byebug"

ENV["ENGINE_ROOT"] = File.dirname(__dir__)

Decidim::Dev.dummy_app_path =
  File.expand_path(File.join(__dir__, "decidim_dummy_app"))

require "decidim/dev/test/base_spec_helper"

# Override decidim-dev's webmock.rb to workaround "Too many open files" problem
WebMock.allow_net_connect!(net_http_connect_on_start: true)
