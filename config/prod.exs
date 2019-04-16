use Mix.Config

config :logger,
  backends: [
    :console,
    {FileLoggerBackend, :error_log}
  ]

config :logger, :console,
  level: :info,
  metadata: [:function, :module, :line]

config :logger, :error_log,
  level: :error,
  path: File.cwd! <> "/log/error.log",
  metadata: [:function, :module, :line]
