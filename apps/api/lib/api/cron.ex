alias API.State

require Logger

defmodule API.Cron do
  def heartbeat() do
    Logger.debug("Cron: Heartbeat")
  end

  def save_state() do
    Logger.debug("Saving State")
    State.save
  end
end
