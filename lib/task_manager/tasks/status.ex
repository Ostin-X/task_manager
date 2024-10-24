defmodule TaskManager.Tasks.Status do
  use Ecto.Schema
  import Ecto.Changeset

  schema "statuses" do
    field :name, :string
    has_many :tasks, TaskManager.Tasks.Task

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(status, attrs) do
    status
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, min: 4, max: 20)
    |> unique_constraint(:name)
  end
end
