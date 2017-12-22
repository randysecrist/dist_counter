defmodule API.Mixfile do
  use Mix.Project

  def project do
    [app: :api,
     version: ChallengeAPI.Mixfile.version,
     elixir: "~> 1.4",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [
      :logger,
      :cowboy,
      :exometer_core,
      :observer_cli],
      mod: {API, []}
    ]
  end

  defp deps do
    [
      {:cowboy, github: "ninenines/cowboy"},
      {:cowlib, github: "ninenines/cowlib", override: true},
      {:gun, github: "ninenines/gun"},
      {:riak_dt, github: "basho/riak_dt", tag: "2.1.4"},
      {:ranch, github: "ninenines/ranch", ref: "1.4.0", override: true},
      {:observer_cli, "~> 1.1.0"},
      {:poison, "~> 3.1"},
      {:json, "~> 1.0"},
      {:quantum, github: "c-rack/quantum-elixir"},
      {:exometer_core, github: "Feuerlabs/exometer_core"},
      {:setup, github: "uwiger/setup", manager: :rebar, override: true},
      {:uuid, github: "okeuday/uuid"},
      {:tzdata, "~> 0.5.12"},
      {:meck, "~> 0.8.4", runtime: false, override: true}
    ]
  end
end
