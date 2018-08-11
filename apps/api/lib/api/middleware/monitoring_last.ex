defmodule API.Monitoring.Last do
  @behaviour :cowboy_middleware
  alias :exometer, as: Exometer
  require Logger

  def execute(req0, env0) do
    before_time = env0[:before_time]
    after_time = System.monotonic_time()
    diff = System.convert_time_unit(after_time - before_time, :native, :microseconds) / 1000
    path = :cowboy_req.path(req0)
    method = :cowboy_req.method(req0)
    # path_info = String.split(path, "/") |> Enum.at(1)
    # metric_name = [path_info, method]
    # update_stat(metric_name ++ [:counter], 1, :counter)
    # update_stat(metric_name ++ [:spiral], 1, :spiral)
    # update_stat(metric_name ++ [:histogram], diff, :histogram)
    Logger.info("path=#{path}, method=#{method}, time=#{diff}ms")
    {:ok, req0, env0}
  end

  defp update_stat(stat, value, type \\ :counter) do
    case Exometer.update(stat, value) do
      {:error, :not_found} ->
        try do
          Exometer.new(stat, type)
          update_stat(stat, value)
        rescue
          _error -> update_stat(stat, value)
        end
      :ok ->
        :ok
    end
  end

end
