defmodule TaskManager.Repo.Migrations.CreateStatuses do
  use Ecto.Migration

  def change do
    create table(:statuses) do
      add :name, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:statuses, [:name])
  end
end
