defmodule API.Response do
  @moduledoc ~S"""
  A standard way of creating a :cowboy_req.reply.

  Adds a CRC to every response for client side cache reasons.

  Also a decent placeholder for logic which reports rate
  limits and simple metadata (header) appending logic.
  """
  alias API.Error, as: E

  def send(req0, %API.Error{} = error) do
    req0 |> send(error.http_code, E.format(error))
  end
  def send(req0, 204) do
    :cowboy_req.reply(204, %{}, "", req0)
  end
  def send(req0, 401) do
    :cowboy_req.reply(401, %{}, "", req0)
  end

  def send(req0, 200, "") do
    :cowboy_req.reply(200,
      %{"access-control-allow-origin" => "*",
        "access-control-allow-headers" => "content-type"}, "", req0)
  end
  def send(req0, status, response_term) do
    send(req0, status, response_term, "application/json")
  end
  def send(req0, status, response_term, content_type) do
    {:ok, json, crc32} = make(response_term)
    :cowboy_req.reply(status,
      %{"content-type" => content_type,
        "access-control-allow-origin" => "*",
        "x-sfn-crc32" => Integer.to_string(crc32)}, json, req0)
  end

  defp make(map) when is_map(map) do
    json = Jason.encode!(map)
    makeCRC(json)
  end
  defp make(list) when is_list(list) do
    json = Jason.encode!(list)
    makeCRC(json)
  end
  defp make(json) when is_binary(json) do
    makeCRC(json)
  end
  defp makeCRC(data) when is_binary(data) do
    crc32 = :erlang.crc32(data)
    {:ok, data, crc32}
  end

end
