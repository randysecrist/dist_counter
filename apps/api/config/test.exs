use Mix.Config

config :api,
  [
    network: [
      {:protocol, :https},
      {:bind, {'0.0.0.0', 8443}},
      {:acceptors, System.schedulers_online * 2},
    ],
    ssl: [
      {:keyfile, System.cwd <> "/priv/ssl/localhost.key"},
      {:certfile, System.cwd <> "/priv/ssl/localhost.crt"}
    ]
]
