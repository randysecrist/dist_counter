use Mix.Config

config :logger,
  backends: [
    {FileLoggerBackend, :error_log},
    {FileLoggerBackend, :access_log}]

config :logger, :access_log,
  level: :info,
  path: System.cwd <> "/log/access.log",
  metadata: [:function, :module, :line]

config :logger, :error_log,
  level: :error,
  path: System.cwd <> "/log/error.log",
  metadata: [:function, :module, :line]
