alias API.Response
alias API.Error, as: E
defmodule API.Post do

  def read_body(conn, acc) do
    read_body_opts = %{
      length: 1048576, # chunks read in this size
      period: 10,
      timeout: 30
    }
    try do
      case :cowboy_req.read_body(conn, read_body_opts) do
        {:ok, data, conn2} -> {:ok, acc <> data, conn2}
        {:more, data, conn2} -> read_body(conn2, acc <> data)
      end
    catch
      :exit, _ -> {:timeout, acc, conn}
    end
  end

  def handle_badlength(conn) do
    Response.send(conn, E.make(:request_too_large))
  end
  
end
