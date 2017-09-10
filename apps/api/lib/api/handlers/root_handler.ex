alias API.Error, as: E
alias API.Response

defmodule API.RootHandler do
  use API.Handler
  def init(req0, opts) do
    method = :cowboy_req.method(req0)
    case method == "OPTIONS" do
      false ->
        req = req0 |> Response.send(E.make(:not_found))
        {:ok, req, opts}
      true ->
        req1 = :cowboy_req.set_resp_header("access-control-allow-methods", "GET PUT POST DELETE OPTIONS", req0)
        req2 = :cowboy_req.set_resp_header("access-control-max-age", "86400", req1)
          |> Response.send(200, "")
        {:ok, req2, opts}
    end
  end
end
