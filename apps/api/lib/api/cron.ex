alias API.State
alias API.NetworkConfig

require Logger

defmodule API.Cron do
  def heartbeat() do
    Logger.debug("Cron: Heartbeat")
  end

  def save_state() do
    Logger.debug("Saving State")
    State.save
  end

  def connect() do
    Logger.debug("Connect")
    actors = NetworkConfig.get_config["actors"]
    actors |> Enum.each(fn(actor) ->
      Node.connect(:"#{actor}@0.0.0.0")
    end)
  end

  defp get_actor_ip(actor) do
    case :inet.gethostbyname(to_charlist(actor)) do
      {_ok, {_hostent, _domain, _, :inet, 4, ip4_list}} ->
        List.first(ip4_list) |> :inet.ntoa |> to_string
      {:error, reason} ->
        Logger.warn("No IP for actor: #{inspect(actor)}, #{inspect(reason)}")
    end
  end

end
