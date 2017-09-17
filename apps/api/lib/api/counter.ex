alias API.Config
alias API.State
alias API.NetworkConfig
alias API.Response
alias API.Error, as: E
alias API.Utils

import API.Post

defmodule API.Counter do
  def get(conn, name, type) do
    case type do
      "consistent_value" ->
        case all_nodes_up?(NetworkConfig.get_config["actors"]) do
          true -> conn |> Response.send(200, State.value(name) |> Integer.to_string)
          false -> conn |> Response.send(500, %{node_down: true})
        end
      "value" -> conn |> Response.send(200, State.value(name) |> Integer.to_string)
      _ -> conn |> Response.send(E.make(:not_found))
    end
  end

  defp all_nodes_up?([]) do
    true
  end
  defp all_nodes_up?(ip_list) do
    length(Node.list) == length(ip_list) - 1
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
