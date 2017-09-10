alias API.Counter
alias API.Error, as: E
alias API.Response
alias API.Utils

defmodule API.CounterHandler do
  use API.Handler
  def init(req0, opts0) do
    method = :cowboy_req.method(req0)
    bindings = :cowboy_req.bindings(req0)
    node_id = Utils.challenge_id()
    {:ok, handle(method, bindings, req0, node_id), opts0}
  end

  def handle("GET", bindings, req0, _node_id) do
    case Map.has_key?(bindings, :name) do
      false -> Response.send(req0, E.make(:not_found))
      true -> Counter.get(req0, bindings[:name], bindings[:type])
    end
  end

  def handle("POST", bindings, req0, node_id) do
    case Map.has_key?(bindings, :name) do
      false -> Response.send(req0, E.make(:not_found))
      true -> Counter.post(req0, bindings[:name], node_id)
    end
  end

  def handle(_, _, req0, _node_id) do
    req0 |> Response.send(E.make(:not_found))
  end
end
