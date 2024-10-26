defmodule TaskManagerWeb.Utils do
  @moduledoc """
  A utility module for handling task-related operations within the Task Manager web application.

  This module provides functions for fetching tasks asynchronously and retrieving a task from the socket
  based on a given ID.

  ## Functions

  - `get_tasks_async_tasks/2`: Fetches tasks and total task count asynchronously.
  - `task_from_socket/2`: Retrieves a task struct from the socket's assigns based on the provided ID.

  ## Examples

      iex> assigns = %{tasks: [%Task{id: 1, title: "Task 1"}, %Task{id: 2, title: "Task 2"}]}
      iex> Utils.task_from_socket("1", %{assigns: assigns})
      %Task{id: 1, title: "Task 1"}

      iex> {task_future, total_future} = Utils.get_tasks_async_tasks(assigns)
      iex> Task.await(task_future)
      [%Task{id: 1, title: "Task 1"}, %Task{id: 2, title: "Task 2"}]
      iex> Task.await(total_future)
      2
  """
  alias TaskManager.Tasks
  alias TaskManager.Tasks.Task, as: MyTask

  @doc """
  Fetches tasks and total task count asynchronously.

  Returns a tuple of two tasks:
  - The first task fetches the list of tasks.
  - The second task fetches the total count of tasks.

  ## Parameters

    - `assigns`: A map containing necessary data for fetching tasks.
    - `opts`: Optional parameters for task retrieval. Default is an empty map.

  ## Examples

      iex> assigns = %{...} # some assigns map
      iex> {task_future, total_future} = Utils.get_tasks_async_tasks(assigns)
  """
  def get_tasks_async_tasks(assigns, opts \\ %{}),
    do: {Task.async(fn -> Tasks.get_tasks(assigns, opts) end), Task.async(fn -> Tasks.total_tasks(assigns, opts) end)}

  @doc """
  Retrieves a task struct from the socket's assigns based on the provided ID.

  This function looks for a task with the given ID in the list of tasks stored in the socket assigns.

  ## Parameters

    - `id`: The ID of the task to retrieve as a string.
    - `socket`: The socket containing assigns with a list of tasks.

  ## Returns

  A task struct if found; otherwise, it returns `nil`.

  ## Examples

      iex> assigns = %{tasks: [%Task{id: 1}, %Task{id: 2}]}
      iex> Utils.task_from_socket("1", %{assigns: assigns})
      %Task{id: 1}

      iex> Utils.task_from_socket("3", %{assigns: assigns})
      nil
  """
  @spec task_from_socket(id :: String.t(), Socket.t()) :: Task.t()
  def task_from_socket(id, %{assigns: %{tasks: tasks}}),
    do: struct(MyTask, Enum.find(tasks, &(&1.id == String.to_integer(id))))

  @doc """
  Converts a UTC datetime to local time and formats it as a string.

  ## Parameters

  - `datetime`: A `DateTime` struct representing a datetime in UTC.

  ## Returns

  - A string representing the datetime in local time formatted as "DD Mon YYYY HH:MM".

  ## Example

      iex> format_datetime_to_local(~U[2024-10-26 14:30:00Z])
      "26 Oct 2024 14:30"
  """
  def format_datetime_to_local(datetime) do
    datetime
    |> Timex.to_datetime("Etc/UTC")
    |> Timex.Timezone.convert(:local)
    |> Timex.format!("{D} {Mshort} {YYYY} {h24}:{m}")
  end

  @doc """
  Slices a string to a specified length and appends "..." if it exceeds that length.

  ## Parameters

  - `str`: The string to be sliced.
  - `len`: The maximum length of the string.

  ## Returns

  - A string that is either the original string (if its length is less than or equal to `len`) or a sliced version with "..." appended.

  ## Example

      iex> string_slice("Hello, World!", 5)
      "Hello..."

      iex> string_slice("Hello", 10)
      "Hello"
  """
  def string_slice(str, len) do
    case String.length(str) > len do
      true -> String.slice(str, 0, len) <> "..."
      false -> str
    end
  end
end
