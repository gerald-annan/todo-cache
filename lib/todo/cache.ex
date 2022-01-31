defmodule Todo.Cache do
  use GenServer

  def init(init_arg \\ %{}) do
    {:ok, init_arg}
  end

  def start(), do: GenServer.start(__MODULE__, %{}, name: __MODULE__)

  def server_process(process_name) do
    GenServer.call(__MODULE__, {:server_process, process_name})
  end

  def handle_call({:server_process, process_name}, _, state) do
    case Map.fetch(state, process_name) do
      {:ok, process_id} ->
        {:reply, process_id, state}

      :error ->
        process = Todo.Server.start(process_name)
        Map.put_new(state, process_name, process)
        {:reply, process, state}
    end
  end
end
