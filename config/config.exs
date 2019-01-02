use Mix.Config

config :ssl, protocol_version: :"tlsv1.2"

# Log format is done here (for consule), in FileLoggerBackend, and monitoring_last.ex
config :logger,
  utc_log: true,
  compile_time_purge_matching: [
    [level_lower_than: :info]
  ],
  # level: :info,
  mode: :async,
  truncate: 4096,
  async_threshold: 75,
  sync_threshold: 100,
  discard_threshold: 300,
  handle_otp_reports: true,
  handle_sasl_reports: false

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
  debug_logging: false,
  timeout: 10_000,
  jobs: [
    [name: "heartbeat", overlap: false, schedule: "* * * * *", task: {API.Cron, :heartbeat, []}, run_strategy: {Quantum.RunStrategy.Random, :cluster}],
    [name: "save_state", overlap: true, schedule: {:extended, "*/5 * * * * *"},
     task: {API.Cron, :save_state, []}, run_strategy: {Quantum.RunStrategy.All, :cluster}]
  ]

config :distillery,
  no_warn_missing: [
    :meck,
  ]

import_config "#{Mix.env}.exs"
import_config "../apps/*/config/config.exs"
import_config "*local.exs"
