# Decidim::Liquidvoting
[![Ruby Style Guide](https://img.shields.io/badge/code_style-rubocop-brightgreen.svg)](https://github.com/rubocop-hq/rubocop)
[![YourActionName Actions Status](https://github.com/liquidvotingio/decidim-module-liquidvoting/workflows/CI/badge.svg)](https://github.com/liquidvotingio/decidim-module-liquidvoting/actions)

Integrates decidim with liquidvoting.io.

**WIP - not ready for production**

## Usage

Liquidvoting will be available as a Component for a Participatory
Space.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "decidim-liquidvoting", git: "https://github.com/liquidvotingio/decidim-module-liquidvoting"
```

And then execute:

```bash
bundle
```

## Running locally, with local API instance

For development, when running a Decidim instance locally with this module bundled, if you want to also run an API instance locally, you'll need to export the following env vars before starting Decidim:

```bash
export LIQUID_VOTING_API_URL="http://localhost:4000"
export LIQUID_VOTING_API_ORG_ID="24e173f5-d99a-4470-b1cc-142b392df10a"
sudo -E bin/rails s --port=80
```

Notes:

We use `sudo` so we can override port 80 - The API doesn't accept proposal urls with ports. The `-E` option so it'll remember the environment variables exported.

For instructions on how to setup the API locally, [see the API repo's README](https://github.com/liquidvotingio/api#local-setup)

## License

This engine is distributed under the GNU AFFERO GENERAL PUBLIC LICENSE.
