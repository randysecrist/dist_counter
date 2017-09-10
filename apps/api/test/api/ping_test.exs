defmodule PingTest do
  use ExUnit.Case, async: true
  import API.Test.Helper

  doctest API

  test "can ping node" do
    %{status: status, body: body} = get("/ping")
    assert status == 200
    assert (JSON.decode!(body) |> Map.get("status")) == "OK"
  end

end
