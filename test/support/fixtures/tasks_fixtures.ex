defmodule TaskManager.TasksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TaskManager.Tasks` context.
  """

  @doc """
  Generate a task.
  """
  def task_fixture(attrs \\ %{}) do
    user = TaskManager.AccountsFixtures.user_fixture()
    status = TaskManager.TasksFixtures.status_fixture()

    {:ok, task} =
      attrs
      |> Enum.into(%{
        description: "some description",
        title: "some title",
        user_id: user.id,
        status_id: status.id
      })
      |> TaskManager.Tasks.create_task()
      |> IO.inspect()

    task
  end

  def status_fixture(attrs \\ %{}) do
    {:ok, status} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> TaskManager.Tasks.create_status()

    status
  end
end
