alias :riak_dt_pncounter, as: PNCounter

require Logger

defmodule API.State do
  use GenServer

  @timeout 500
  @file_path "data/" <> Atom.to_string(Mix.env) <> "_" <> "state"
  def file(), do: @file_path

  # public API
  def update_counter_state(actor, counter_name, counter_value, timeout \\ @timeout) do
    GenServer.call(__MODULE__, {actor, counter_name, counter_value}, timeout)
  end
  def view(timeout \\ @timeout) do
    GenServer.call(__MODULE__, :view, timeout)
  end
  def save(new_state, timeout \\ @timeout) do
    GenServer.call(__MODULE__, {:save, new_state}, timeout)
  end
  def value(counter_name, timeout \\ @timeout) do
    state = view(timeout) |> Map.get(counter_name)
    case state do
      nil -> 0
      _ -> state |> PNCounter.value
    end
  end
  def merge(local_state, timeout \\ @timeout) do
    Node.list |> Enum.reduce(local_state, fn (node, acc) ->
      remote_state = GenServer.call({__MODULE__, node}, :view, timeout)
      case is_map(remote_state) do
        true -> merge_state(acc, remote_state)
        false ->
          Logger.warn("Merge Error: #{inspect(remote_state)}")
          local_state
      end
    end)
  end

  defp merge_state(new, old) do
    Map.merge(new, old, fn _k, l, r -> PNCounter.merge(l, r) end)
  end

  # All the usual suspects for GenServer
  def start_link({:options, options}) do
    initial_state = options[:initial_state]
    GenServer.start_link(__MODULE__, initial_state, name: __MODULE__)
  end
  def init(state0) do
    Process.flag(:trap_exit, true)
    result = File.read(@file_path)
    state1 = case result do
      {:error, :enoent} -> state0
      {:ok, data} ->
        state0 |> Map.merge(:erlang.binary_to_term(data))
    end
    {:ok, state1}
  end
  def terminate(_reason, state) do
    :error_logger.info_msg('API.State:  Shutting Down')
    write_file(state)
  end
  def handle_call(:view, _from, state) do
    {:reply, state, state}
  end
  def handle_call({:save, new_state}, _from, state) do
    state1 = merge_state(new_state, state) |> write_file
    {:reply, :ok, state1}
  end
  def handle_call({actor, counter_name, counter_value}, _from, state) do
    # always do a local read before write
    {_current_value, state1} = state |> Map.get_and_update(counter_name, fn current_value ->
      new_value = case current_value do
        nil ->
          {:ok, c1} = PNCounter.update({:increment, counter_value}, actor, PNCounter.new())
          c1
        _ ->
          {:ok, c1} = PNCounter.update({:increment, counter_value}, actor, current_value)
          c1
      end
      {current_value, new_value}
    end)
    response = state1 |> Map.get(counter_name, 0) |> PNCounter.value
    {:reply, response, state1}
  end
  def handle_call(_msg, _from, state) do
    {:reply, :error, state}
  end

  defp write_file(state) do
    File.mkdir("data")
    File.write(@file_path, :erlang.term_to_binary(state), [:binary])
    state
  end

  # we don't care about async updates for now
  # def handle_cast(msg, state) do
  #   {:noreply, state}
  # end
end
