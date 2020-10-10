# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/liquidvoting/version"

Gem::Specification.new do |s|
  s.version = Decidim::Liquidvoting::VERSION
  s.authors = ["Oliver Azevedo Barnes"]
  s.email = ["oliverbarnes@hey.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/liquidvotingio/decidim-liquidvoting"
  s.required_ruby_version = ">= 2.5"

  s.name = "decidim-liquidvoting"
  s.summary = "A Decidim Liquidvoting module"
  s.description = "Integrates decidim with liquidvoting.io."

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  # TODO: figure out if we need decidim-admin and decidim-proposals as dependencies
  s.add_dependency "decidim-core", Decidim::Liquidvoting::DECIDIM_VERSION

  s.add_development_dependency "decidim-dev", Decidim::Liquidvoting::DECIDIM_VERSION
end
