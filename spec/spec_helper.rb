# frozen_string_literal: true

require "decidim/dev"

ENV["ENGINE_ROOT"] = File.dirname(__dir__)

# TODO: is this a team-friendly location for the generated test app? Is the DECIDIM_VERSION at gen-time important?
Decidim::Dev.dummy_app_path = File.expand_path(File.join("..", "decidim", "spec", "decidim_dummy_app"))
# Decidim::Dev.dummy_app_path = File.expand_path(File.join(__dir__, "decidim_dummy_app"))

require "decidim/dev/test/base_spec_helper"
