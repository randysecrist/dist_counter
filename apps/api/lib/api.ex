alias API.Config
alias API.Monitoring
alias API.PingHandler
alias API.RootHandler
alias API.ConfigHandler
alias API.CounterHandler

defmodule API do
  use Application

  def start(_type, _args) do
    start_link()
  end

  def stop(_state) do
    :cowboy.stop_listener(:api_listener)
  end

  def start_link() do
    import Supervisor.Spec, warn: false
    children = [
      {API, %{}},
      {API.State, %{}},
      worker(API.Scheduler, [])
    ]
    opts = [strategy: :one_for_one, name: API.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def child_spec(opts) when is_map(opts) do
    {cowboy_fun, ranch_opts, cowboy_opts} = configure_cowboy()
    %{
      id: __MODULE__,
      start: {:cowboy, cowboy_fun, [:api_listener, ranch_opts, cowboy_opts]},
      type: :worker,
      restart: :transient,
      shutdown: 500
    }
  end

  defp configure_cowboy() do
    # build our routing table
    dispatch = :cowboy_router.compile([
      {:_, [
        {"/ping", PingHandler, []},
        {"/config", ConfigHandler, []},
        {"/counter/:name", CounterHandler, []},
        {"/counter/:name/:type", CounterHandler, []},
        {:_, RootHandler, []}
      ]}
    ])
    {cowboy_start_fun, protocol_opts} = case Config.get_protocol do
      :http ->  {:start_clear, nil}
      :https -> {:start_tls, get_ssl_opts()}
    end
    {cowboy_start_fun, ranch_tcp_opts(protocol_opts), cowboy_opts(dispatch)}
  end

  defp ranch_tcp_opts(protocol_opts) do
    {raw_ip, port} = Config.get_bind_address()
    {_, ip} = :inet.parse_address(raw_ip)
    tcp_options = [
      {:ip, ip},
      {:port, port},
      {:num_acceptors, Config.get_num_acceptors()},
      {:max_connections, 16_384},
      {:backlog, 32_768},
    ]
    case protocol_opts do
      nil -> tcp_options
      _ -> tcp_options ++ protocol_opts
    end
  end

  defp cowboy_opts(dispatch) do
    %{
      env: %{dispatch: dispatch},
      middlewares: [
        Monitoring.First,
        :cowboy_router,
        :cowboy_handler,
        Monitoring.Last
      ],
      # onresponse: &API.Monitoring.Last.execute/4
      stream_handlers: [:cowboy_compress_h, :cowboy_stream_h]
    }
  end

  defp get_ssl_opts() do
    [{:cacertfile, Config.get_ssl_cacertfile()},
     {:certfile, Config.get_ssl_certfile()},
     {:keyfile, Config.get_ssl_keyfile()},
     {:versions, [:'tlsv1.2', :'tlsv1.1', :'tlsv1']}]
  end

end
