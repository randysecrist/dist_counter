defmodule ChallengeAPI.Mixfile do
  use Mix.Project

  require Logger

  @version "0.0.1-dev"

  {:ok, system_version} = Version.parse(System.version)
  @elixir_version {system_version.major, system_version.minor, system_version.patch}

  def project do
    Logger.debug("Challenge #{@version}: using Elixir: #{inspect(@elixir_version)}")
    [apps_path: "apps",
     version: @version,
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def version do
    @version
  end

  defp deps do
    [{:dialyxir, "~> 0.5", only: [:dev], runtime: false},
     {:ex_doc, "~> 0.15.0", only: :dev, runtime: false}]
  end
end
