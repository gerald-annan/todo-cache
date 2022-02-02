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

    {:ok, {0, workers}}
  end

  def next(active_worker), do: if(active_worker < @workers, do: active_worker + 1, else: 0)
  def choose_worker(workers, active_worker), do: workers |> Map.fetch!(active_worker)

  def handle_cast(msg, {active_worker, workers}) do
    Todo.DatabaseWorker.store(msg, choose_worker(workers, active_worker))
    {:noreply, {next(active_worker), workers}}
  end

  def handle_call(msg, caller, {active_worker, workers}) do
    Todo.DatabaseWorker.get(msg, caller, choose_worker(workers, active_worker))
    {:noreply, {next(active_worker), workers}}
  end
end
