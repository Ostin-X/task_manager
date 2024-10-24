defmodule TaskManager.Tasks.Queries do
  @moduledoc false
  import Ecto.Query, only: [from: 2]
  alias TaskManager.{Repo, Tasks.Task, Tasks.Status}

  #  defp get_role_operator_stuff_query(query, status_selected, _) when role_id != 0,
  #    do: from(u in query, where: u.role_id == ^role_id)
  #
  #  defp get_role_operator_stuff_query(query, _, operator_id, true) when operator_id != 0,
  #    do: from(u in query, where: u.operator_id == ^operator_id)
  #
  #  defp get_role_operator_stuff_query(query, _, operator_id, _) when operator_id != 0,
  #    do: from(u in query, where: u.operator_id == ^operator_id or is_nil(u.operator_id))
  #
  #  defp get_role_operator_stuff_query(query, _, _, true),
  #    do: from(u in query, where: not is_nil(u.role_id) or u.is_superuser == true)
  #
  #  defp get_role_operator_stuff_query(query, _, _, _), do: query

  def get_tasks_query(
        %{
          sort: [{sort_key, sort_order}],
          current_page: current_page,
          on_page_limit: limit,
          filter: filter,
          status_selected: status_selected
        } = assigns
      ) do
    sort_order = if sort_order == "DESC", do: :desc, else: :asc
    offset = max(0, (current_page - 1) * limit)

    query =
      from(t in Task,
        left_join: u in assoc(t, :user),
        left_join: s in assoc(t, :status),
        where:
          ilike(t.title, ^"%#{filter}%") or
            fragment("CAST(? AS TEXT) ILIKE ?", t.id, ^"%#{filter}%"),
        order_by: [{^sort_order, field(t, ^sort_key)}],
        limit: ^limit,
        offset: ^offset,
        select: %{t | user: %{id: u.id, name: u.email}, status: %{id: s.id, name: s.name}}
      )

    #    get_role_operator_stuff_query(
    #      query,
    #      status_selected
    #    )
  end

  def total_pages_from_query(
        %{
          filter: filter,
          status_selected: status_selected
        } = assigns
      ) do
    query =
      from t in Task,
        where:
          ilike(t.title, ^"%#{filter}%") or
            fragment("CAST(? AS TEXT) ILIKE ?", t.id, ^"%#{filter}%")

    #    query =
    #      get_role_operator_stuff_query(
    #        query,
    #        role_selected,
    #        operator_selected,
    #        Map.get(assigns, :is_stuff)
    #      )

    Repo.aggregate(query, :count, :id)
  end
end
