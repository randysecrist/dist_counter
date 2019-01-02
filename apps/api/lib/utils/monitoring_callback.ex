defmodule API.Monitoring do
  alias :exometer, as: Exometer
  require Logger

  @moduledoc ~S"""
  This callback is defined by the metrics_callback cowboy option
  and invoked by the cowboy_metrics_h stream handler module.

  This fully replaces the API.Monitoring.{First,Last} middleware.
  """
  def metrics_callback(%{req: %{method: method, path: path, version: version}, resp_status: status,
                         req_body_length: req_body_length,
                         resp_body_length: resp_body_length,
                         req_start: req_start, req_end: _req_end,
                         resp_start: _resp_start, resp_end: resp_end} = _metrics) do
    diff = System.convert_time_unit(resp_end - req_start, :native, :microseconds) / 1000

    # For Later when we want Stats
    # path_info = String.split(path, "/") |> Enum.at(2)
    # metric_name = [path_info, method]
    # update_stat(metric_name ++ [:counter], 1, :counter)
    # update_stat(metric_name ++ [:spiral], 1, :spiral)
    # update_stat(metric_name ++ [:histogram], diff, :histogram)
    Logger.info("#{inspect(version)}, #{inspect(path)}, #{inspect(method)}, #{inspect(status)}, #{inspect(req_body_length)}, #{inspect(resp_body_length)} | #{diff}ms")
  end
  def metrics_callback(%{reason: {:connection_error, :protocol_error, reason}} = _metrics) do
    Logger.warn("Protocol Error: #{inspect(reason)}")
  end
  def metrics_callback(metrics) do
    Logger.warn("Unexpected Metrics: #{inspect(metrics)}")
  end

  defp update_stat(stat, value, type \\ :counter) do
    case Exometer.update(stat, value) do
      {:error, :not_found} ->
        Exometer.new(stat, type)
        update_stat(stat, value)
      :ok ->
        :ok
    end
  end
end
