defmodule Todo.Database do
  use GenServer
  @workers 3
  @db_folder "./persist"

  def start do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
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
      |> Enum.map(fn _ -> Todo.DatabaseWorker.start() end)
      |> Enum.with_index(fn element, index -> {index, element} end)
      |> Enum.into(%{})

    {:ok, workers}
  end

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
