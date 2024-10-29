defmodule TaskManagerWeb.GlobalSetup do
  @moduledoc """
  Script for online DB population
  """
  alias TaskManager.Repo
  alias TaskManager.Tasks.{Status, Task}
  alias TaskManager.Accounts.User

  def run do
    migrate()
    delete_all_records()

    # Define statuses
    statuses = [
      %{"name" => "pending"},
      %{"name" => "in_progress"},
      %{"name" => "completed"}
    ]

    # Insert statuses into the database
    for status <- statuses do
      %Status{}
      |> Status.changeset(status)
      |> Repo.insert!()
    end

    # Create users
    users = [
      %User{}
      |> User.registration_changeset(%{username: "admin", email: "admin@admin.com", password: "admin"})
      |> Repo.insert!(),
      %User{}
      |> User.registration_changeset(%{username: "admin2", email: "admin2@admin.com", password: "admin"})
      |> Repo.insert!(),
      %User{}
      |> User.registration_changeset(%{username: "admin3", email: "admin3@admin.com", password: "admin"})
      |> Repo.insert!()
    ]

    # Get the inserted statuses
    status_ids = Repo.all(Status) |> Enum.map(& &1.id)

    # Use lorem to generate random titles and descriptions for tasks
    for _ <- 1..31 do
      user = Enum.random(users)
      status = Enum.random(status_ids)

      %Task{}
      |> Task.changeset(%{
        title: Faker.Lorem.sentence() |> String.slice(0..49),
        description: Faker.Lorem.paragraph() |> String.slice(0..199),
        user_id: user.id,
        status_id: status
      })
      |> Repo.insert!()
    end

    IO.puts("Database seeded with 3 users, 3 statuses, and 60 tasks.")
  end

  defp migrate do
    Ecto.Migrator.run(Repo, :up, all: true)
  end

  defp delete_all_records do
    Repo.delete_all(Task)
    Repo.delete_all(Status)
    Repo.delete_all(User)
  end
end
