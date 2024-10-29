defmodule TaskManager.Tasks.Queries do
  @moduledoc """
  Provides functions to construct Ecto queries for tasks, including
  filtering, sorting, and pagination.

  This module contains functions to build queries to fetch tasks
  based on various parameters and to compute the total number of
  pages based on filtering criteria.

  ## Functions

  ### `get_tasks_query/1`

  Constructs a query to fetch tasks based on provided filtering,
  sorting, pagination, and status parameters.

  #### Parameters
  - `params` (map):
    A map containing the following keys:
    - `:sort` - A list of tuples where the first element is the
      field to sort by (as an atom) and the second element is the
      sort order ("ASC" or "DESC").
    - `:current_page` - An integer representing the current page
      number for pagination.
    - `:on_page_limit` - An integer defining the limit of tasks
      per page.
    - `:filter` - A string used for filtering tasks based on the
      task title or ID.
    - `:status_selected` - An integer representing the selected
      status ID for filtering tasks. A value of 0 indicates no
      specific status filter.

  #### Returns
  - An Ecto query that can be executed to retrieve the filtered,
    sorted, and paginated list of tasks.

  ### `base_filtered_tasks_query/1`

  Constructs a base query for filtering tasks based on the title
  or ID, and the selected status.

  #### Parameters
  - `params` (map):
    A map containing the following keys:
    - `:filter` - A string used for filtering tasks based on the
      task title or ID.
    - `:status_selected` - An integer representing the selected
      status ID for filtering tasks. A value of 0 indicates no
      specific status filter.

  #### Returns
  - An Ecto query that represents the filtered tasks based on
    the given criteria.

  ## Example Usage

  To retrieve tasks based on specific filtering, sorting, and
  pagination criteria:

      params = %{
        sort: [{:title, "ASC"}],
        current_page: 1,
        on_page_limit: 10,
        filter: "example",
        status_selected: 0
      }

      query = TaskManager.Tasks.Queries.get_tasks_query(params)
      tasks = Repo.all(query)
  """
  import Ecto.Query, only: [from: 2]

  def get_tasks_query(%{
        sort: [{sort_key, sort_order}],
        current_page: current_page,
        on_page_limit: limit,
        filter: filter,
        status_selected: status_selected
      }) do
    sort_order = if sort_order == "DESC", do: :desc, else: :asc
    offset = max(0, (current_page - 1) * limit)

    from(t in base_filtered_tasks_query(%{filter: filter, status_selected: status_selected}),
      left_join: u in assoc(t, :user),
      left_join: s in assoc(t, :status),
      order_by: [{^sort_order, field(t, ^sort_key)}],
      limit: ^limit,
      offset: ^offset,
      select: %{t | user: %{id: u.id, email: u.email}, status: %{id: s.id, name: s.name}}
    )
  end

  def base_filtered_tasks_query(%{filter: filter, status_selected: status_selected}) do
    query =
      from t in TaskManager.Tasks.Task,
        where:
          ilike(t.title, ^"%#{filter}%") or
            fragment("CAST(? AS TEXT) ILIKE ?", t.id, ^"%#{filter}%")

    case status_selected == 0 do
      true -> query
      _ -> from(t in query, where: t.status_id == ^status_selected)
    end
  end
end
