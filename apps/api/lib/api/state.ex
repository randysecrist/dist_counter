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
  def save(timeout \\ @timeout) do
    GenServer.call(__MODULE__, :save, timeout)
  end
  def value(counter_name, timeout \\ @timeout) do
    state = view(timeout) |> Map.get(counter_name)
    case state do
      nil -> 0
      _ -> state |> PNCounter.value
    end
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
    save_state(state)
  end
  def handle_call(:view, _from, state) do
    {:reply, state, state}
  end
  def handle_call(:save, _from, state) do
    save_state(state)
    {:reply, :ok, state}
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

  defp merge_state(local_state) do
    case :rpc.multicall(Node.list, API.State, :view, [], 500) do
      {remote_state_list, []} ->
        remote_state_list |> Enum.reduce(local_state, fn(remote_state, acc) ->
          # acc == local_accumulator, l == local state, r == remote state
          Map.merge(acc, remote_state, fn _k, l, r -> PNCounter.merge(l, r) end)
        end)
      {[], []} -> local_state
      error -> {:merge_error, error}
    end
  end

  defp save_state(state0) do
    state1 = merge_state(state0)
    case state1 do
      {:merge_error, error} ->
        Logger.error("Merge Failure: #{inspect(error)}")
      _ ->
        File.mkdir("data")
        File.write(@file_path, :erlang.term_to_binary(state1), [:binary])
    end
  end

  # we don't care about async updates for now
  # def handle_cast(msg, state) do
  #   {:noreply, state}
  # end
end
