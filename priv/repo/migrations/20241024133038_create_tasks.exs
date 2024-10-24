defmodule TaskManager.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :title, :string
      add :description, :string
      add :user_id, references(:users, on_delete: :delete_all)
      add :status_id, references(:statuses, on_delete: :restrict)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:tasks, [:title])
    create index(:tasks, [:user_id])
    create index(:tasks, [:status_id])
  end
end
