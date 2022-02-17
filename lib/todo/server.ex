defmodule Todo.Server do
  use GenServer

  def init(name) do
    IO.puts("Starting database server...")
    {:ok, {name, Todo.List.new()}}
  end

  def start_link(name) do
    IO.puts("Starting to-do server for #{name}")
    GenServer.start_link(Todo.Server, name, name: via_tuple(name))
  end

  def via_tuple(key), do: Todo.ProcessRegistry.via_tuple(key)

  def add_entry({:ok, server_id}, entry) do
    GenServer.cast(server_id, {:add_entry, entry})
  end

  @spec entries({:ok, atom | pid | {atom, any} | {:via, atom, any}}, any) :: any
  def entries({:ok, server_id}, value) do
    GenServer.call(server_id, {:entries, value})
  end

  def handle_call({:entries, key}, _, {_, todo_list} = state) do
    {:reply, Todo.List.entries(key, todo_list), state}
  end

  def handle_cast({:add_entry, entry}, {name, todo_list}) do
    new_list = Todo.List.add(todo_list, entry)
    Todo.Database.store(name, new_list)
    {:noreply, {name, new_list}}
  end
end
