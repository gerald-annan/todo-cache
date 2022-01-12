defmodule Todo.Server do
  use GenServer

  def init(_init_arg \\ []) do
    {:ok, []}
  end

  def start(), do: GenServer.start(__MODULE__, nil)

  def add_entry({:ok, server_id}, entry) do
    GenServer.cast(server_id, {:add_entry, entry})
  end

  def entries({:ok, server_id}, key) do
    GenServer.call(server_id, {:entries, key})
  end

  def handle_call({:entries, key}, _, state) do
    {:reply, Todo.List.entries(key, state), state}
  end

  def handle_cast({:add_entry, entry}, state) do
    {:noreply, state ++ [entry]}
  end
end
