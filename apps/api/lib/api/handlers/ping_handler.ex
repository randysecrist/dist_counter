alias API.Response

defmodule API.PingHandler do
  use API.Handler
  def init(req0, opts) do
    req = req0 |> Response.send(200, %{status: "OK"})
    {:ok, req, opts}
  end
end
