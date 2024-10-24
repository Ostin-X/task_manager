defmodule TaskManager.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :description, :string
    field :title, :string

    belongs_to :user, TaskManager.Accounts.User
    belongs_to :status, TaskManager.Tasks.Status

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task, attrs \\ %{}) do
    task
    |> cast(attrs, [:title, :description, :user_id, :status_id])
    |> validate_required([:title, :description, :user_id, :status_id])
    |> validate_length(:title, min: 4, max: 50)
    |> validate_length(:description, min: 4, max: 200)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:status_id)
    |> unique_constraint(:title)
  end
end
