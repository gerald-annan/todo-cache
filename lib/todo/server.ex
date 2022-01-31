defmodule Todo.Server do
  use GenServer

  def init(name) do
    {:ok, {name, []}}
  end

  def start(process_name), do: GenServer.start(__MODULE__, process_name)

  def add_entry({:ok, server_id}, entry) do
    GenServer.cast(server_id, {:add_entry, entry})
  end

  def entries({:ok, server_id}, key) do
    GenServer.call(server_id, {:entries, key})
  end

  def handle_call({:entries, key}, _, {_, todo_list} = state) do
    {:reply, Todo.List.entries(key, todo_list), state}
  end

  def handle_cast({:add_entry, entry}, {name, todo_list} = state) do
    {:noreply, {name, Todo.List.add(todo_list, entry)}
  end
end
