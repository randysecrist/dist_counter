use Mix.Config

config :ssl, protocol_version: :"tlsv1.2"

config :logger,
  backends: [
    {FileLoggerBackend, :error_log},
    {FileLoggerBackend, :access_log}],
  utc_log: true,
  compile_time_purge_level: :debug,
  truncate: 4096

config :logger, :access_log,
  path: System.cwd <> "/log/access.log",
  metadata: [:function, :module],
  level: :info

config :logger, :error_log,
  path: System.cwd <> "/log/error.log",
  metadata: [:function, :module],
  level: :error

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
   [name: "save_state", schedule: {:extended, "*/5 * * * * *"},
    task: {API.Cron, :save_state, []}, run_strategy: {Quantum.RunStrategy.All, [node()]}]
 ]


import_config "../apps/*/config/config.exs"
import_config "*local.exs"
