alias API.NetworkConfig
alias API.Error, as: E
alias API.Response

defmodule API.ConfigHandler do
  use API.Handler
  def init(req0, opts0) do
    method = :cowboy_req.method(req0)
    bindings = :cowboy_req.bindings(req0)
    {:ok, handle(method, bindings, req0), opts0}
  end

  def handle("GET", _bindings, req0) do
    NetworkConfig.get(req0)
  end

  def handle("POST", _bindings, req0) do
    NetworkConfig.post(req0)
  end

  def handle(_, _, req0) do
    req0 |> Response.send(E.make(:not_found))
  end
end
