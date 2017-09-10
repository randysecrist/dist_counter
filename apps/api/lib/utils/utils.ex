require Logger

defmodule API.Utils do
  def gen_uuidv1() do
    {uuid_v1, _} = :uuid.get_v1(:uuid.new(self(), :erlang))
    to_string(:uuid.uuid_to_string(uuid_v1))
  end

  def gen_uuidv4() do
    to_string(:uuid.uuid_to_string(:uuid.get_v4(:strong)))
  end

  def to_struct(attrs, kind) do
    struct = struct(kind)
    Enum.reduce Map.to_list(struct), struct, fn {k, _}, acc ->
      case Map.fetch(attrs, Atom.to_string(k)) do
        {:ok, v} -> %{acc | k => v}
        :error -> acc
      end
    end
  end

  def challenge_id() do
    case System.get_env("CHALLENGE_ID") do
      nil -> "DEFAULT"
      id -> id
    end
  end

  @spec get(String.t, integer(), String.t) :: binary()
  def get(host, port, query_string, timeout \\ 100) do
    :application.ensure_all_started(:gun)
    {:ok, pid} = :gun.open(host, port, %{})
    stream_ref = :gun.get(pid, query_string)
    read_stream(pid, stream_ref, timeout)
  end
  defp read_stream(pid, stream_ref, timeout) do
    case :gun.await(pid, stream_ref, timeout) do
    	{:response, :fin, status, headers} ->
    		%{status: status, headers: headers}
    	{:response, :nofin, status, headers} ->
    		{:ok, body} = :gun.await_body(pid, stream_ref)
        %{body: body, headers: headers, status: status}
      {:error, :timeout} -> {:error, :timeout}
    end
  end

end
