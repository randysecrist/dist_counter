alias :riak_dt_pncounter, as: PNCounter

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
  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end
  def init(state0) do
    result = File.read(@file_path)
    state1 = case result do
      {:error, :enoent} -> state0
      {:ok, data} ->
        state0 |> Map.merge(:erlang.binary_to_term(data))
    end
    {:ok, state1}
  end
  def handle_call(:view, _from, state) do
    {:reply, state, state}
  end
  def handle_call(:save, _from, state) do
    File.mkdir("data")
    File.write(@file_path, :erlang.term_to_binary(state), [:binary])
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

  # we don't care about async updates for now
  # def handle_cast(msg, state) do
  #   {:noreply, state}
  # end
end
