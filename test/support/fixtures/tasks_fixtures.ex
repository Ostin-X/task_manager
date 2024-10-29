defmodule TaskManager.TasksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TaskManager.Tasks` context.
  """

  import TaskManager.AccountsFixtures

  @doc """
  Generate a task.
  """
  def task_fixture(attrs \\ %{}) do
    user = Map.get(attrs, :user) || user_fixture()
    status = Map.get(attrs, :status) || status_fixture()
    title = Map.get(attrs, :title) || "some title"

    {:ok, task} =
      attrs
      |> Enum.into(%{
        description: "some description",
        title: title,
        user_id: user.id,
        status_id: status.id
      })
      |> TaskManager.Tasks.create_task()

    task
  end

  def create_tasks_fixture(attrs \\ %{}) do
    users = Map.get(attrs, :users)
    statuses = Map.get(attrs, :statuses)
    number = Map.get(attrs, :number) || 10

    for i <- 1..number,
        do: task_fixture(%{user: Enum.random(users), status: Enum.random(statuses), title: "some title #{i}"})
  end

  def status_fixture(attrs \\ %{}) do
    name = Map.get(attrs, :name) || "some name"

    {:ok, status} =
      attrs
      |> Enum.into(%{
        name: name
      })
      |> TaskManager.Tasks.create_status()

    status
  end

  def create_statuses_fixture(attrs \\ %{}) do
    number = Map.get(attrs, :number) || 2
    status_names = ["pending"] ++ for i <- 2..number, do: "some name #{i}"

    for name <- status_names, do: status_fixture(%{name: name})
  end

  def setup_database(_context) do
    user1 = user_fixture()
#    user2 = user_fixture()
    users = [user1]

    [status1, status2] = create_statuses_fixture(%{number: 2})
    statuses = [status1, status2]

    create_tasks_fixture(%{users: users, statuses: statuses, number: 30})

    {:ok, user1: user1, status1: status1, status2: status2}
  end
end
