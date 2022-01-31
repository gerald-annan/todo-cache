defmodule Todo.Database do
  use GenServer
  @db_folder "./persist"

  def start do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end
end
