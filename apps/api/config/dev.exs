use Mix.Config

config :api,
  [
    network: [
      {:protocol, :http},
      {:bind, {'0.0.0.0', 7777}},
      {:acceptors, System.schedulers_online * 2},
    ]
  ]
