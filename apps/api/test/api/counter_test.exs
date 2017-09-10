alias API.State

defmodule CounterTest do
  use ExUnit.Case, async: true
  import API.Test.Helper

  doctest API

  setup do
    on_exit fn ->
      wait_until fn ->
        File.rm(State.file())
      end
    end
  end

  test "/counter is not found" do
    wait_until fn ->
      response = get("/counter")
      assert 404 = response[:status]
    end
  end

  test "fails if input is not an integer" do
    input = "A"
    wait_until fn ->
      response = post(input, "/counter/foo")
      assert 400 = response[:status]
    end
  end

  test "can update counter at least once" do
    input = "2"
    wait_until fn ->
      response = post(input, "/counter/foo")
      assert 204 = response[:status]
    end
  end

end
