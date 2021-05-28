# Decidim::Liquidvoting
[![Ruby Style Guide](https://img.shields.io/badge/code_style-rubocop-brightgreen.svg)](https://github.com/rubocop-hq/rubocop)
[![YourActionName Actions Status](https://github.com/liquidvotingio/decidim-module-liquidvoting/workflows/CI/badge.svg)](https://github.com/liquidvotingio/decidim-module-liquidvoting/actions)

Integrates Decidim with the [liquidvoting.io API](https://www.liquidvoting.io/api).

**Note: In alpha**. Not yet used in production. But it's ready for a pilot!

https://user-images.githubusercontent.com/21290/120000386-a952b180-bfca-11eb-9e94-82b875048b6b.mp4

The integration enables delegations of supports for proposals in participatory processes and assemblies, and redirects supports so they go through the API, in order to calculate results based on different voting weights of delegates.


## Installation

Add this line to the Decidim instance's Gemfile:

```ruby
gem "decidim-liquidvoting", git: "https://github.com/liquidvotingio/decidim-module-liquidvoting"
```

And then execute:

```bash
bundle
```

By default the instance will connect with the live api hosted on https://api.liquidvoting.io/, and use a demo organization there.

For use with your own organization [please contact us](mailto:info@liquidvoting.io) to request an authentication key.

If a private on-prem instance of the API is preferred, [see the instructions on the API repo](https://github.com/liquidvotingio/api) on how to use the docker image.

## Running locally, with a local API instance

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
