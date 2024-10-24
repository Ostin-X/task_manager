defmodule TaskManagerWeb.TasksHandleEvents do
  @moduledoc """
  Handle events for account
  """
  use Surface.Component

  alias Moon.Design.{Drawer, Snackbar, Modal}
  alias TaskManager.Tasks
  alias TaskManager.Tasks.Task, as: MyTask
  alias TaskManagerWeb.Utils

  def handle_event(
        "validate",
        %{"user" => params},
        %{assigns: %{form: %{data: task_data}}} = socket
      ) do
    form =
      task_data
      |> Tasks.changeset(params)
      |> Map.put(:action, :insert)
      |> to_form

    {:noreply, assign(socket, form: form)}
  end

#  def handle_event(
#        "update",
#        _,
#        %{assigns: %{form: %{data: task_data, params: params}}} = socket
#      ) do
#    case params != %{} && Tasks.update_task(task_data, params) do
#      {:ok, user} ->
#        Drawer.close("admin_drawer")
#        Snackbar.open("snackbar_updated")
#
#        {:noreply, assign(socket, form: to_form(User.no_pass_changeset(user, params)), selected: [])}
#
#      {:error, changeset} ->
#        {:noreply, assign(socket, form: to_form(changeset))}
#
#      false ->
#        {:noreply, socket}
#    end
#  end
#
#  def handle_event(
#        "delete",
#        _,
#        %{assigns: %{form: %{data: user_data}}} = socket
#      ) do
#    case Accounts.delete_user(user_data) do
#      {:ok, _user} ->
#        Drawer.close("admin_drawer")
#        Modal.close("approve")
#        Snackbar.open("snackbar_deleted")
#
#        {:noreply, socket}
#
#      {:error, _changeset} ->
#        {:noreply, socket}
#    end
#  end

  def handle_event("pagination_click", %{"value" => current_page}, %{assigns: assigns} = socket) do
    current_page = String.to_integer(current_page)

    {:noreply,
     assign(socket,
       tasks: Tasks.get_tasks(assigns, %{current_page: current_page}),
       current_page: current_page
     )}
  end

  def render(_assigns), do: "Nothing to render"
end
