defmodule TaskManagerWeb.Utils do
  @moduledoc false
  #  alias TaskManagerWeb.FilterChangeset

  alias TaskManager.Tasks

  #  import Phoenix.Component, only: [to_form: 1]

  def get_tasks_async_tasks(assigns, opts \\ %{}),
    do: {Task.async(fn -> Tasks.get_tasks(assigns, opts) end), Task.async(fn -> Tasks.total_tasks(assigns, opts) end)}

  @spec task_from_socket(id :: String.t(), Socket.t()) :: Task.t()
  def task_from_socket(id, %{assigns: %{tasks: tasks}}),
    do: struct(User, Enum.find(tasks, &(&1.id == String.to_integer(id))))
end
