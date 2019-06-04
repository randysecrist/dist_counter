use Mix.Config

config :logger,
  backends: [
    {FileLoggerBackend, :access_log},
    {FileLoggerBackend, :error_log}
  ]

config :logger, :access_log,
  level: :info,
  path: File.cwd! <> "/log/access.log",
  metadata: [:function, :module, :line]

config :logger, :error_log,
  level: :error,
  path: File.cwd! <> "/log/error.log",
  metadata: [:function, :module, :line]
