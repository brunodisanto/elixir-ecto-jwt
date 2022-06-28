# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :easymarketplace, EasymarketplaceWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "KT/lkoimRu46WFr3PSnV0VEblxWsBexPRqjqWpBT/SOKGeudSTIi8mxhL4+l0aca",
  render_errors: [view: EasymarketplaceWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Easymarketplace.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :easymarketplace, Easymarketplace.Guardian,
  issuer: "easymarketplace",
  allowed_algos: ["HS256"],
  secret_key: "minhachaveultrasecreta",
  ttl: {1, :days}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
