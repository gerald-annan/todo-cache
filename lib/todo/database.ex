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
    {:ok, {0, 1..@workers |> Enum.map(fn _ -> Todo.DatabaseWorker.start() end)}}
  end

  def next(active_worker), do: if(active_worker < @workers, do: active_worker + 1, else: 0)

  def handle_cast(msg, {active_worker, workers}) do
    workers
    |> Enum.fetch!(active_worker)
    |> send(msg)

    {:noreply, {next(active_worker), workers}}
  end

  def handle_call(msg, caller, {active_worker, workers}) do
    workers
    |> Enum.fetch!(active_worker)
    |> send({msg, caller})

    {:noreply, {next(active_worker), workers}}
  end
end
