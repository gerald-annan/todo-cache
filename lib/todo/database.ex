defmodule Todo.Database do
  use GenServer
  @workers 3
  @db_folder "./persist"

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def store(key, data) do
    GenServer.cast(__MODULE__, {:store, key, data})
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  def init(_) do
    File.mkdir_p!(@db_folder)

    workers =
      1..@workers
      |> Enum.map(fn _ ->
        IO.puts("Starting database worker...")
        Todo.DatabaseWorker.start_link()
      end)
      |> Enum.with_index(fn element, index -> {index, element} end)
      |> Enum.into(%{})

    {:ok, workers}
  end

  @spec choose_worker(map, any) :: any
  def choose_worker(workers, key), do: workers |> Map.fetch!(:erlang.phash2(key, 3))

  def handle_cast({_, key, _} = msg, state) do
    Todo.DatabaseWorker.store(msg, choose_worker(state, key))
    {:noreply, state}
  end

  def handle_call({_, key} = msg, caller, state) do
    Todo.DatabaseWorker.get(msg, caller, choose_worker(state, key))
    {:noreply, state}
  end
end
