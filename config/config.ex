import Config

config :logger,
  level: :debug,
  format: "$time $metadata[$level] $message\n",
  backends: [:console]
