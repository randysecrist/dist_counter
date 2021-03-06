alias API.Response
alias API.Error, as: E
alias API.Utils

import API.Post

defmodule API.NetworkConfig do

  @file_path "data/" <> Atom.to_string(Mix.env) <> "_" <> "config"
  def file(), do: @file_path

  def get_config() do
    case File.read(@file_path) do
      {:error, :enoent} ->
        case System.get_env("ACTORS") do
          nil -> %{"actors" => []}
          value -> Jason.decode!(value)
        end
      {:ok, data} -> :erlang.binary_to_term(data)
    end
  end

  def get(conn) do
    response = get_config()
      |> Map.put("challenge_id", Utils.challenge_id())
      |> Map.put("connected_nodes", Node.list)
    conn |> Response.send(200, response)
  end

  def post(conn) do
    resp_or_json = case read_body(conn, "") do
      {:ok, body, conn2} -> handle_body(conn2, body)
      {:more, _, conn2} -> handle_badlength(conn2)
      {:timeout, _, conn2} -> Response.send(conn2, E.make(:request_timeout))
    end
    case is_map(resp_or_json) do
      true ->
        save(resp_or_json)
        Response.send(conn, 204)
      false -> Response.send(conn, E.make(:invalid_argument))
    end
  end

  def delete(conn) do
    case File.rm!(@file_path) do
      :ok -> Response.send(conn, 204)
      _ -> Response.send(conn, E.make(:not_found))
    end
  end

  defp handle_body(_conn, body) when is_binary(body) do
    Jason.decode!(body)
  end

  defp save(term) when is_map(term) do
    File.mkdir("data")
    File.write(@file_path, :erlang.term_to_binary(term), [:binary])
  end
end
