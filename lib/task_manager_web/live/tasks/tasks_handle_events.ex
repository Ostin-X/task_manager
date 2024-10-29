defmodule TaskManagerWeb.TasksHandleEvents do
  @moduledoc """
  Provides event handlers for task-related actions within the Task Manager interface.

  This module defines the logic for handling the following events:
    - `validate` - Validates task data as a user inputs or edits it.
    - `create` - Handles the creation of new tasks with the specified parameters.
    - `update` - Updates existing tasks if there are changes in parameters.
    - `delete` - Deletes a specified task and provides UI feedback.
    - `pagination_click` - Manages pagination to display specific pages of tasks.

  Each event function updates the UI and displays notifications or modals to confirm successful
  operations or to show validation errors.
  """
  use Surface.Component

  alias Moon.Design.{Snackbar, Modal, Drawer}
  alias TaskManager.Tasks
  alias TaskManager.Tasks.Task, as: MyTask
  alias TaskManagerWeb.DrawerComponent

  # Validates task data based on the parameters provided by the user.
  # Adds the current user's ID to the parameters before validation and returns an updated form 
  # with any validation errors.
  def handle_event(
        "validate",
        %{"task" => params},
        %{assigns: %{form: %{data: task_data}, current_user: %{id: user_id}}} = socket
      ) do
    params = Map.put_new(params, "user_id", user_id)

    form =
      task_data
      |> MyTask.changeset(params)
      |> Map.put(:action, :insert)
      |> to_form

    {:noreply, assign(socket, form: form)}
  end

  # Creates a new task with the current form parameters and assigns the user ID.
  # If creation succeeds, closes the drawer, displays a "created" snackbar, and resets the form.
  # On failure, updates the form to display errors.
  def handle_event(
        "create",
        _,
        %{assigns: %{form: %{params: params}, current_user: %{id: user_id}, default_form: form}} = socket
      ) do
    params = Map.put_new(params, "user_id", user_id)

    case Tasks.create_task(params) do
      {:ok, _task} ->
        #        DrawerComponent.handle_event("drawer_on_close", %{}, socket)
        Drawer.close("tasks_drawer")
        Snackbar.open("snackbar_created")

        {:noreply, assign(socket, form: form)}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}

      false ->
        {:noreply, socket}
    end

    {:noreply, socket}
  end

  # Updates an existing task if there are changes in the parameters.
  # On success, closes the drawer, displays an "updated" snackbar, and resets the form.
  # If validation fails, updates the form with the relevant error messages.
  def handle_event(
        "update",
        _,
        %{assigns: %{form: %{data: task_data, params: params}, default_form: form}} = socket
      ) do
    case params != %{} && Tasks.update_task(task_data, params) do
      {:ok, _task} ->
        DrawerComponent.handle_event("drawer_on_close", %{}, socket)
        Snackbar.open("snackbar_updated")

        {:noreply, assign(socket, form: form)}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}

      false ->
        {:noreply, socket}
    end
  end

  # Deletes the specified task, providing UI feedback through modal and snackbar notifications.
  # On success, closes the drawer and modal, and opens a "deleted" snackbar.
  def handle_event(
        "delete",
        _,
        %{assigns: %{form: %{data: user_data}}} = socket
      ) do
    case Tasks.delete_task(user_data) do
      {:ok, _task} ->
#        DrawerComponent.handle_event("drawer_on_close", %{}, socket)
        Modal.close("approve_delete")
        Snackbar.open("snackbar_deleted")

        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  # Handles pagination clicks, updating the current page to display the relevant tasks.
  # Parses the clicked page, retrieves tasks for that page, and assigns them to the socket.
  def handle_event("pagination_click", %{"value" => current_page}, %{assigns: assigns} = socket) do
    current_page = String.to_integer(current_page)

    {:noreply,
     assign(socket,
       tasks: Tasks.get_tasks(assigns, %{current_page: current_page}),
       current_page: current_page
     )}
  end

  def render(_), do: nil
end
