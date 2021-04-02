# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

# Inside the development app, the relative require has to be one level up, as
# the Gemfile is copied to the development_app folder (almost) as is.
base_path = ""
base_path = "../" if File.basename(__dir__) == "development_app"
require_relative "#{base_path}lib/decidim/liquidvoting/version"

gem "decidim", Decidim::Liquidvoting::DECIDIM_VERSION
gem "decidim-proposals", Decidim::Liquidvoting::DECIDIM_VERSION
gem "decidim-liquidvoting", path: "."

gem "bootsnap", "~> 1.4"
gem "puma", ">= 5.0"
gem "uglifier", "~> 4.1"

# Fixes CI build error where it can't find v0.1.1
gem "declarative-option", "0.1.0"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri
  gem "rubocop"
  gem "rubocop-performance"
  gem "rubocop-rails"
  gem "rubocop-rspec" # or gem 'rubocop-minitest'

  gem "decidim-dev", Decidim::Liquidvoting::DECIDIM_VERSION
end

group :development do
  gem "faker", "~> 2.14"
  gem "letter_opener_web", "~> 1.3"
  gem "listen", "~> 3.1"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console", "~> 3.5"
end

group :test do
  gem "codecov", require: false
  gem "shoulda-matchers"
  gem "simplecov-cobertura", require: false
end
