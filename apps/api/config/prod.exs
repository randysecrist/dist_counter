use Mix.Config

config :api,
  [
    network: [
      {:protocol, :http},
      {:bind, {'0.0.0.0', 7777}},
      {:acceptors, System.schedulers_online * 2},
    ],
    ssl: [
      {:keyfile, File.cwd! <> "/priv/ssl/__challenge_com.key"},
      {:certfile, File.cwd! <> "/priv/ssl/__challenge_com.crt"},
      {:cacertfile, File.cwd! <> "/priv/ssl/__challenge_com.ca-bundle"}
    ]
  ]
