defmodule ChallengeAPI.Mixfile do
  use Mix.Project

  def project do
    [apps_path: "apps",
     version: "0.0.1-dev",
     elixir: "~> 1.4",
     start_permanent: Mix.env == :prod,
     deps: deps(),
     test_coverage: [tool: ExCoveralls],
     dialyzer_warnings: [
       :unmatched_returns,
       :error_handling,
       :race_conditions,
       :underspecs,
       :unknown],
     dialyzer_ignored_warnings: [
       {:warn_contract_supertype, :_, :_}]
     ]
  end

  defp deps do
    [{:dialyzex, "~> 1.2.1", only: [:dev], runtime: false},
     {:ex_doc, "~> 0.20.2", only: :dev, runtime: false},
     {:observer_cli, "~> 1.4.2"},
     {:meck, "~> 0.8.13", runtime: false, only: :test, override: true},
     {:faker, "~> 0.12.0", runtime: false, only: :test},
     {:excoveralls, "~> 0.10.6", only: :test},
     {:distillery, "~> 2.0.12"}]
  end
end
