defmodule ChallengeAPI.Mixfile do
  use Mix.Project

  def project do
    [apps_path: "apps",
     version: "0.0.1-dev",
     elixir: "~> 1.4",
     start_permanent: Mix.env == :prod,
     deps: deps(),
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
    [{:dialyzex, "~> 1.0.0", only: [:dev], runtime: false},
     {:ex_doc, "~> 0.15.0", only: :dev, runtime: false},
     {:observer_cli, "~> 1.2.1"},
     {:distillery, "~> 1.5"}]
  end
end
