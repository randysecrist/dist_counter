alias API.NetworkConfig

defmodule ConfigTest do
  use ExUnit.Case, async: true
  import API.Test.Helper

  doctest API

  setup do
    on_exit fn ->
      File.rm(NetworkConfig.file())
    end
  end

  test "/config contains actors and challenge id" do
    wait_until fn ->
      response = get("/config")
      assert 200 == response[:status]
      body_map = JSON.decode!(response[:body])
      assert [] == body_map["actors"]
      assert "DEFAULT" == body_map["challenge_id"]
    end
  end

  test "/config saves Network Config" do
    assert %{"actors" => []} == NetworkConfig.get_config()
    input = load_fixture("config.json")
    wait_until fn ->
      response = post(input, "/config")
      assert 204 = response[:status]
      assert %{"actors" => [
        "1.2.3.4", "1.2.3.5", "1.2.3.6"
      ]} == NetworkConfig.get_config()
    end
  end
  
end
