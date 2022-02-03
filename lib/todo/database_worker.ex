defmodule Todo.DatabaseWorker do
  @db_folder "./persist"

  def start do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    {:ok, @db_folder}
  end

  def get(msg, caller, {_, worker_pid}) do
    GenServer.call(worker_pid, {msg, caller})
  end

  def store(msg, {_, worker_pid}) do
    GenServer.cast(worker_pid, msg)
  end

  def handle_cast({:store, key, data}, state) do
    spawn(fn ->
      key
      |> file_name(state)
      |> File.write!(:erlang.term_to_binary(data))
    end)

    {:noreply, state}
  end

  def handle_call({{:get, key}, caller}, _, state) do
    spawn(fn ->
      data =
        case File.read(file_name(key, state)) do
          {:ok, contents} -> :erlang.binary_to_term(contents)
          _ -> nil
        end

      GenServer.reply(caller, data)
    end)

    {:noreply, state}
  end

  defp file_name(key, folder) do
    Path.join(folder, to_string(key))
  end
end
