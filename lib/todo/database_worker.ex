defmodule Todo.DatabaseWorker do
  use GenServer
  @db_folder "./persist"

  def start_link({_db_folder, worker_id}) do
    IO.puts("Starting database worker #{worker_id}")
    GenServer.start_link(
      __MODULE__,
      nil,
      name: via_tuple(worker_id) ## registration
    )
  end

  @spec init(any) :: {:ok, <<_::72>>}
  def init(_) do
    {:ok, @db_folder}
  end

  def get(worker_id, msg, caller) do
    # GenServer.call(worker_pid, {msg, caller})
    GenServer.call(via_tuple(worker_id), {msg, caller})
  end

  def store(worker_id, msg) do
    # GenServer.cast(worker_pid, msg)
    GenServer.cast(via_tuple(worker_id), msg)
  end

  defp via_tuple(worker_id) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, worker_id})
  end

  def handle_cast({:store, key, data}, state) do
    key
    |> file_name(state)
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, state}
  end

  def handle_call({{:get, key}, caller}, _, state) do
    data =
      case File.read(file_name(key, state)) do
        {:ok, contents} -> :erlang.binary_to_term(contents)
        _ -> nil
      end

    GenServer.reply(caller, data)
    {:noreply, state}
  end

  defp file_name(key, folder) do
    Path.join(folder, to_string(key))
  end
end
