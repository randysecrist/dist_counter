alias API.Config
alias API.State
alias API.NetworkConfig
alias API.Response
alias API.Error, as: E
alias API.Utils

import API.Post

defmodule API.Counter do
  def get(conn, name, nil) do
    conn |> Response.send(200, State.value(name) |> Integer.to_string)
  end

  def get(conn, name, type) do
    case NetworkConfig.get_config["actors"] do
      [] -> get(conn, name, nil) # local result only
      ip_list -> multi_get(conn, name, type, ip_list)
    end
  end

  defp multi_get(conn, name, type, ip_list) do
    sum = ip_list |> Enum.reduce_while(0, fn(ip, acc) ->
      # 7777 is the only available port open between nodes
      {_, port} = Config.get_bind_address()
      result = Utils.get(to_charlist(ip), port, "/counter/#{name}")
      maybe_cnt = case result do
        {:error, :timeout} ->
          case type do
            "consistent_value" -> {:inconsistent, ip}
            _ -> 0
          end
        _ ->
          result
            |> Map.get(:body)
            |> String.to_integer
      end
      case maybe_cnt do
        {:inconsistent, _} -> {:halt, maybe_cnt}
        _ -> {:cont, acc + maybe_cnt}
      end
    end)
    case sum do
      {:inconsistent, bad_ip} ->
        conn |> Response.send(500, %{node_timeout: bad_ip})
      _ ->
        conn |> Response.send(200, sum |> Integer.to_string)
    end
  end

  def post(conn, name, node_id) do
    case read_body(conn, "") do
      {:ok, body, conn2} -> handle_body(conn2, body, name, node_id)
      {:more, _, conn2} -> handle_badlength(conn2)
      {:timeout, _, conn2} -> Response.send(conn2, E.make(:request_timeout))
    end
  end

  defp handle_body(conn, body, name, node_id) when is_binary(body) do
    try do
      State.update_counter_state(node_id, name, String.to_integer(body))
      Response.send(conn, 204)
    rescue
      _error -> Response.send(conn, E.make(:validation_failure))
    end
  end

end
