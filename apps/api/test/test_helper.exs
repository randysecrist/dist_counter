alias API.Config

ExUnit.start(timeout: 5000)

defmodule API.Test.Helper do
  use ExUnit.Case, async: true

  @spec load_fixture(String.t) :: binary()
  def load_fixture(fixture_file) do
    {:ok, binary} = File.read "test/fixtures/" <> fixture_file
    binary
  end

  @spec get(String.t) :: binary()
  def get(url) do
    :application.ensure_all_started(:gun)
    {_, port} = Config.get_bind_address()
    options = case Config.get_protocol do
      :http -> %{}
      _ -> %{:transport => :ssl}
    end
    {:ok, pid} = :gun.open('localhost', port, options)
    stream_ref = :gun.get(pid, url)
    read_stream(pid, stream_ref)
  end

  @spec post(String.t, String.t) :: binary()
  def post(body, url) do
    :application.ensure_all_started(:gun)
    {_, port} = Config.get_bind_address()
    options = case Config.get_protocol do
      :http -> %{}
      _ -> %{:transport => :ssl}
    end
    {:ok, pid} = :gun.open('localhost', port, options)
    stream_ref = :gun.post(pid, url, [
      {"content-type", 'application/txt'}
    ], body)
    read_stream(pid, stream_ref)
  end

  defp read_stream(pid, stream_ref) do
    case :gun.await(pid, stream_ref) do
    	{:response, :fin, status, headers} ->
    		%{status: status, headers: headers}
    	{:response, :nofin, status, headers} ->
    		{:ok, body} = :gun.await_body(pid, stream_ref)
        %{body: body, headers: headers, status: status}
    end
  end

  @spec wait_until(integer(), function()|function()) :: any()
  def wait_until(fun), do: wait_until(500, fun)
  def wait_until(0, fun), do: fun.()
  def wait_until(timeout, fun) do
    try do
      fun.()
    rescue
      _ ->
        :timer.sleep(10)
        wait_until(max(0, timeout - 10), fun)
    end
  end
end
