defmodule Todo.Cache do
  use GenServer

  def init(init_arg \\ %{}) do
    send(self(), :real_init)
    {:ok, init_arg}
  end

  def handle_info(:real_init, state) do
    {:noreply, state}
  end

  def start_link(_) do
    IO.puts("Starting to-do cache")

    DynamicSupervisor.start_link(
      name: __MODULE__,
      strategy: :one_for_one
    )
  end

  defp start_child(todo_list_name) do
    DynamicSupervisor.start_child(
      __MODULE__,
      {Todo.Server, todo_list_name}
    )
  end

  def child_spec(_arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  def server_process(process_name) do
    GenServer.call(__MODULE__, {:server_process, process_name})
  end

  def handle_call({:server_process, process_name}, _, state) do
    case Map.fetch(state, process_name) do
      {:ok, process_id} ->
        {:reply, process_id, state}

      :error ->
        process = Todo.Server.start_link(process_name)
        Map.put_new(state, process_name, process)
        {:reply, process, state}
    end
  end
end
