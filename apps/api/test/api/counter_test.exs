alias API.State
alias API.Utils

defmodule CounterTest do
  use ExUnit.Case, async: true
  import API.Test.Helper

  doctest API

  setup do
    counter_name = Utils.gen_uuidv4()
    wait_until fn ->
      response = post("2", "/counter/#{counter_name}")
      assert 204 == response[:status]
    end
    on_exit fn ->
      wait_until fn ->
        File.rm(State.file())
      end
    end
    [counter_name: counter_name]
  end

  test "/counter is not found" do
    wait_until fn ->
      response = get("/counter")
      assert 404 == response[:status]
    end
  end

  test "fails if input is not an integer" do
    input = "A"
    wait_until fn ->
      response = post(input, "/counter/foo")
      assert 400 == response[:status]
    end
  end

  test "can fetch a counter value", context do
    wait_until fn ->
      response = get("/counter/#{context[:counter_name]}/value")
      assert 200 == response[:status]
      assert "2" == response[:body]
    end
  end

  test "can fetch a counter's consistent value", context do
    wait_until fn ->
      response = get("/counter/#{context[:counter_name]}/consistent_value")
      assert 200 == response[:status]
      assert "2" == response[:body]
    end
  end

end
