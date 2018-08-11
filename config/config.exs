use Mix.Config

config :ssl, protocol_version: :"tlsv1.2"

# Log format is done here (for consule), in FileLoggerBackend, and monitoring_last.ex
config :logger,
  backends: [
    :console,
    {FileLoggerBackend, :error_log},
    {FileLoggerBackend, :access_log}],
  utc_log: true,
  compile_time_purge_level: :debug,
  truncate: 4096

config :logger, :console,
  level: :debug,
  # TODO: figure out how to suppress logs from external modules
  # metadata: [:module, :function, :line],
  format: "[$date,$time] [$level] [$node|#{Mix.env}], $metadata$levelpad$message\n"

config :logger, :access_log,
  level: :info
  path: System.cwd <> "/log/access.log",
  metadata: [:module, :function, :line],

config :logger, :error_log,
  level: :error
  path: System.cwd <> "/log/error.log",
  metadata: [:module, :function, :line],

# if a process decides to have a uuid cache
config :quickrand,
  cache_size: 65536

# prevent exometer from creating spurious directories
config :setup,
  verify_directories: false

# configure tzdata to autoupdate and use a data dir
config :tzdata, [
  autoupdate: :enabled,
  data_dir: "./data"]

config :api, API.Scheduler,
  global: true,
  jobs: [
    [name: "heartbeat", overlap: false, schedule: "* * * * *", task: {API.Cron, :heartbeat, []}, run_strategy: {Quantum.RunStrategy.Random, :cluster}],
    [name: "save_state", overlap: true, schedule: {:extended, "*/5 * * * * *"},
     task: {API.Cron, :save_state, []}, run_strategy: {Quantum.RunStrategy.All, :cluster}]
  ]

config :distillery,
  no_warn_missing: [
    :meck,
  ]

import_config "../apps/*/config/config.exs"
import_config "*local.exs"
