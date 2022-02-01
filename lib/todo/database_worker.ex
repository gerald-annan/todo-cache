defmodule Todo.DatabaseWorker do
  def start() do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    {:ok, nil}
  end
end
