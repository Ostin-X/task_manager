defmodule TaskManagerWeb.GlobalSetup do
  @moduledoc """
  Script for online DB population
  """
  def run do
    alias TaskManager.Repo
    alias TaskManager.Tasks.{Status, Task}
    # Make sure this alias matches your User context
    alias TaskManager.Accounts.User

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
      |> User.registration_changeset(%{username: "admin", email: "admin@admin", password: "admin"})
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
    for i <- 1..31 do
      # Assign a user and status to each task
      user = Enum.random(users)
      status = Enum.random(status_ids)

      %Task{}
      |> Task.changeset(%{
        # Generates a random title
        title: Faker.Lorem.sentence() |> String.slice(0..49),
        # Generates a random description
        description: Faker.Lorem.paragraph() |> String.slice(0..199),
        # Assuming your Task schema has a user_id field
        user_id: user.id,
        # Assuming your Task schema has a status_id field
        status_id: status
      })
      |> Repo.insert!()
    end

    IO.puts("Database seeded with 3 users, 3 statuses, and 60 tasks.")
  end
end
