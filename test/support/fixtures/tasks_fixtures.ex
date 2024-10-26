defmodule TaskManager.TasksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TaskManager.Tasks` context.
  """

  @doc """
  Generate a task.
  """
  def task_fixture(attrs \\ %{}) do
    user = Map.get(attrs, :user) || TaskManager.AccountsFixtures.user_fixture()
    status = Map.get(attrs, :status) || TaskManager.TasksFixtures.status_fixture()
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
    for i <- 1..number, do: task_fixture(%{user: Enum.random(users), status: Enum.random(statuses), title: "some title #{i}"})
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
    for i <- 1..number, do: status_fixture(%{name: "some name #{i}"})
  end
end
