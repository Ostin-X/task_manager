# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     TaskManager.Repo.insert!(%TaskManager.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

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

# Create regular users
users =
  for i <- 1..10 do
    %User{}
    |> User.registration_changeset(%{
      username: "user_#{i}",
      email: "user_#{i}@example.com",
      password: "password123"
    })
    |> Repo.insert!()
  end

# Add the admin user
admin_user =
  %User{}
  |> User.registration_changeset(%{username: "admin", email: "admin@admin", password: "admin"})
  |> Repo.insert!()

# Get the inserted statuses
status_ids = Repo.all(Status) |> Enum.map(& &1.id)

# Create tasks
for i <- 1..60 do
  # Assign a user and status to each task
  # Include admin in the pool of users
  user = Enum.random(users ++ [admin_user])
  status = Enum.random(status_ids)

  %Task{}
  |> Task.changeset(%{
    title: "Task #{i}",
    description: "Description for Task #{i}",
    # Assuming your Task schema has a user_id field
    user_id: user.id,
    # Assuming your Task schema has a status_id field
    status_id: status
  })
  |> Repo.insert!()
end

IO.puts("Database seeded with 10 regular users, an admin user, 3 statuses, and 60 tasks.")
