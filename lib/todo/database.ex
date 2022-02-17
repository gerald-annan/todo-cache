defmodule Todo.Database do
  use GenServer
  @pool_size 3
  @db_folder "./persist"

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def store(key, data) do
    GenServer.cast(__MODULE__, {:store, key, data})
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  def init(_) do
    IO.puts("Starting database server...")
    File.mkdir_p!(@db_folder)

    children = Enum.map(1..@pool_size, &worker_spec/1)
    Supervisor.start_link(children, strategy: :one_for_one)

    # workers =
    #   1..@pool_size
    #   |> Enum.map(fn _ ->
    #     IO.puts("Starting database worker...")
    #     Todo.DatabaseWorker.start_link()
    #   end)
    #   |> Enum.with_index(fn element, index -> {index, element} end)
    #   |> Enum.into(%{})

    {:ok, children}
  end

  defp worker_spec(worker_id) do
    default_worker_spec = {Todo.DatabaseWorker, {@db_folder, worker_id}}
    Supervisor.child_spec(default_worker_spec, id: worker_id)
  end

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  def choose_worker(key), do: :erlang.phash2(key, @pool_size) + 1

  def handle_cast({_, key, _} = msg, state) do
    key
    |> choose_worker() 
    |> Todo.DatabaseWorker.store(msg)
    ## all the tendencies of database persistence
    {:noreply, state}
  end

  def handle_call({_, key} = msg, caller, state) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.get(msg, caller)

    {:noreply, state}
  end
end
