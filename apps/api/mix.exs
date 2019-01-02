defmodule API.Mixfile do
  use Mix.Project

  def project do
    [app: :api,
     version: "0.0.1-dev",
     elixir: "~> 1.6",
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
      {:cowboy, github: "ninenines/cowboy", tag: "2.5.0"},
      {:cowlib, github: "ninenines/cowlib", tag: "2.6.0", override: true},
      {:ranch, github: "ninenines/ranch", ref: "1.6.2", override: true},
      {:gun, "~> 1.3.0", override: true},
      {:riak_dt, github: "basho/riak_dt", tag: "2.1.4"},
      {:poison, "~> 4.0.1"},
      {:json, "~> 2.1.0-SNAPSHOT"},
      {:quantum, github: "c-rack/quantum-elixir"},
      {:exometer_core, github: "Feuerlabs/exometer_core"},
      {:setup, github: "uwiger/setup", manager: :rebar, override: true},
      {:parse_trans, "~> 3.3.0", override: true},
      {:uuid, "~> 1.7.3", hex: :uuid_erl},
      {:tzdata, "~> 0.5.17"},
      {:meck, "~> 0.8.12", runtime: false, override: true}
    ]
  end
end
