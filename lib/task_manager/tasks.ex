defmodule TaskManager.Tasks do
  @moduledoc """
  The Tasks context.
  """

  import Ecto.Query, warn: false
  alias TaskManager.Repo

  alias TaskManager.Tasks.{Task, Status, Queries}

  @topic inspect(__MODULE__)

  def subscribe do
    Phoenix.PubSub.subscribe(TaskManager.PubSub, @topic)
  end

  defp broadcast_change({:ok, result}, event) do
    Phoenix.PubSub.broadcast(TaskManager.PubSub, @topic, {__MODULE__, event, result})
    {:ok, result}
  end

  defp broadcast_change({:error, reason}, _event), do: {:error, reason}

  def get_tasks(assigns, opts \\ %{}), do: Map.merge(assigns, opts) |> fetch_tasks

  defp fetch_tasks(assigns) do
    Queries.get_tasks_query(assigns)
    |> Repo.all()
    |> Enum.map(&Map.from_struct/1)
  end

  def total_tasks(assigns, opts \\ %{}),
    do: Map.merge(assigns, opts) |> Queries.base_filtered_tasks_query() |> Repo.aggregate(:count, :id)

  @doc """
  Returns the list of tasks.

  ## Examples

      iex> list_tasks()
      [%Task{}, ...]

  """
  def list_tasks do
    Repo.all(Task)
  end

  @doc """
  Gets a single task.

  Raises `Ecto.NoResultsError` if the Task does not exist.

  ## Examples

      iex> get_task!(123)
      %Task{}

      iex> get_task!(456)
      ** (Ecto.NoResultsError)

  """
  def get_task!(id), do: Repo.get!(Task, id)

  @doc """
  Creates a task.

  ## Examples

      iex> create_task(%{field: value})
      {:ok, %Task{}}

      iex> create_task(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_task(attrs \\ %{}) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
    |> broadcast_change([:task, :created])
  end

  @doc """
  Updates a task.

  ## Examples

      iex> update_task(task, %{field: new_value})
      {:ok, %Task{}}

      iex> update_task(task, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_task(%Task{} = task, attrs) do
    task
    |> Task.changeset(attrs)
    |> Repo.update()
    |> broadcast_change([:task, :updated])
  end

  @doc """
  Deletes a task.

  ## Examples

      iex> delete_task(task)
      {:ok, %Task{}}

      iex> delete_task(task)
      {:error, %Ecto.Changeset{}}

  """
  def delete_task(%Task{} = task) do
    Repo.delete(task)
    |> broadcast_change([:task, :deleted])
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking task changes.

  ## Examples

      iex> change_task(task)
      %Ecto.Changeset{data: %Task{}}

  """
  def change_task(%Task{} = task, attrs \\ %{}) do
    Task.changeset(task, attrs)
  end

  @doc """
  Returns the list of statuses.

  ## Examples

      iex> list_statuses()
      [%Status{}, ...]

  """
  def list_statuses() do
    Repo.all(Status)
  end

  @doc """
  Gets a single status.

  Raises `Ecto.NoResultsError` if the Status does not exist.

  ## Examples

      iex> get_status!(123)
      %Status{}

      iex> get_status!(456)
      ** (Ecto.NoResultsError)

  """
  def get_status!(id), do: Repo.get!(Status, id)

  @doc """
  Fetches and formats the list of statuses for use in a dropdown.

  This function retrieves all statuses and formats them as a list of maps,
  where each map includes a `:value` key with the status ID and a `:key` key with the status name.
  It is primarily used for populating a dropdown menu with status options.

  ## Examples

      iex> get_status_options()
      [%{value: 1, key: "Open"}, %{value: 2, key: "In Progress"}, %{value: 3, key: "Closed"}]

  """
  def get_status_options(),
    do: list_statuses() |> Enum.map(fn %Status{id: id, name: name} -> %{value: id, key: name} end)

    def create_status(attrs \\ %{}) do
      %Status{}
      |> Status.changeset(attrs)
      |> Repo.insert()
    end
end
