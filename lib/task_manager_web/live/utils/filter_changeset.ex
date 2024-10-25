defmodule TaskManagerWeb.FilterChangeset do
  @moduledoc """
  Provides a changeset for handling search and filter parameters on the tasks table.

  This changeset is used to validate and manage the `status_id` and `filter` parameters
  from the search form, enabling the application to filter tasks based on status and title.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @doc """
  Schema definition for task filters.

  Fields:
    * `status_id` - The ID of the status to filter tasks by. An integer representing the selected status filter.
    * `filter` - A string for searching tasks by title or ID.
  """
  schema "placeholder_changesets" do
    field :status_id, :integer
    field :filter, :string
  end

  @doc """
  Builds a changeset for filtering tasks.

  ## Parameters
    - `filter` - The initial filter data.
    - `params` - Parameters to cast into the changeset.

  ## Returns
    - Changeset for filtering tasks based on `status_id` and `filter` fields.
  """
  def filter_changeset(filter, params \\ %{}) do
    filter
    |> cast(params, [:status_id, :filter])
  end
end
