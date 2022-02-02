defmodule Todo.DatabaseWorker do
  @db_folder "./persist"

  def start(db_folder) do
    GenServer.start(__MODULE__, db_folder, name: __MODULE__)
  end

  def init(db_folder) do
    {:ok, nil}
  end

  def handle_cast({:store, key, data}, state) do
    spawn(fn ->
      key
      |> file_name()
      |> File.write!(:erlang.term_to_binary(data))
    end)

    {:noreply, state}
  end

  def handle_call({{:get, key}, caller}, _, state) do
    spawn(fn ->
      data =
        case File.read(file_name(key)) do
          {:ok, contents} -> :erlang.binary_to_term(contents)
          _ -> nil
        end

      GenServer.reply(caller, data)
    end)

    {:noreply, state}
  end

  defp file_name(key) do
    Path.join(@db_folder, to_string(key))
  end
end
