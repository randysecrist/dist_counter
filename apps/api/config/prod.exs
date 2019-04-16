use Mix.Config

config :api,
  [
    network: [
      {:protocol, :https},
      {:bind, {'0.0.0.0', 443}},
      {:acceptors, System.schedulers_online * 4},
    ],
    ssl: [
      {:keyfile, File.cwd! <> "/priv/ssl/__challenge_com.key"},
      {:certfile, File.cwd! <> "/priv/ssl/__challenge_com.crt"},
      {:cacertfile, File.cwd! <> "/priv/ssl/__challenge_com.ca-bundle"}
    ]
  ]
