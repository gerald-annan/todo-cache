defmodule Todo.List do
  def new() do
    []
  end

  def add(todoList, new_entry) do
    todoList ++ [new_entry]
  end

  def entries(value, todoList) do
    Enum.filter(todoList, fn item ->
      item[:date] == value or item[:title] == value
    end)
  end
end
