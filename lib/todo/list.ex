defmodule Todo.List do
  def new() do
    []
  end

  def add(todoList, new_entry) do
    todoList ++ [new_entry]
  end

  def entries(key, todoList) do
    Enum.filter(todoList, fn item ->
      item[:date] == key or item[:title] == key
    end)

    todoList
  end
end
