alias API.State
alias API.NetworkConfig

require Logger

defmodule API.Cron do
  def heartbeat() do
    Logger.info("Cron: Heartbeat")
    connect()
  end

  def save_state() do
    Logger.info("Saving State")
    State.view |> State.merge |> State.save
  end

  defp connect() do
    Logger.info("Connect")
    case length(Node.list) == length(NetworkConfig.get_config["actors"]) - 1 do
      false ->
        actors = NetworkConfig.get_config["actors"]
        actors |> Enum.each(fn(actor) ->
          Node.connect(:"#{actor}@#{get_actor_ip(actor)}")
        end)
      true -> :ok
    end
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
