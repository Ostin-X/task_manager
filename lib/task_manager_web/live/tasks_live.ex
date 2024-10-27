defmodule TaskManagerWeb.TasksLive do
  @moduledoc """
  Live view module for managing tasks in the Task Manager application.

  This module handles task-related live interactions, including displaying a list of tasks,
  creating, updating, deleting tasks, and managing task-related UI components such as
  filters, forms, drawers, and modals.

  ## Data Definitions

  - `tasks`: The list of tasks to display.
  - `selected`: The list of selected task in the table to highlight.
  - `sort`: The current sorting order of tasks.
  - `current_page`: The current page of tasks being displayed.
  - `total_tasks`: The total number of tasks available.
  - `total_pages`: The total number of pages based on the task limit.
  - `on_page_limit`: The maximum number of tasks displayed per page.
  - `filter`: The current filter string for tasks.
  - `filter_form`: The form for managing task filters.
  - `loading`: Indicates whether the data is currently loading.
  - `status_options`: The list of options of statuses for tasks.
  - `status_selected`: The currently selected status option in the dropdown filter.
  - `drawer_title`: The title of the drawer component.
  - `is_open`: Indicates whether the drawer is open.
  - `form`: The form for creating or updating a task.
  - `default_form`: The default form state for tasks.
  """
  use TaskManagerWeb, :surface_live_view

  alias Moon.Design.Loader

  alias TaskManager.Tasks.Task, as: MyTask
  alias TaskManager.Tasks

  alias TaskManagerWeb.{
    TasksHandleEvents,
    TasksTableComponent,
    DrawerComponent,
    SnackbarComponent,
    DeleteModalComponent,
    TasksFilterComponent,
    TasksFormComponent,
    FilterChangeset,
    Utils
  }

  data tasks, :list, default: []
  data selected, :list, default: []
  data sort, :keyword, default: [id: "ASC"]
  data current_page, :integer, default: 1
  data total_tasks, :integer, default: 0
  data total_pages, :integer, default: 1
  data on_page_limit, :integer, default: 10
  data filter, :string, default: ""
  data filter_form, :form, default: to_form(FilterChangeset.filter_changeset(%FilterChangeset{}, %{"status_id" => 0}))
  data loading, :boolean, default: true
  data status_options, :list, default: []
  data status_selected, :integer, default: 0

  data drawer_title, :string, default: ""
  data is_open, :boolean, default: false
  data form, :form, default: to_form(MyTask.changeset(%MyTask{}))
  data default_form, :form, default: to_form(MyTask.changeset(%MyTask{}))
  data viewer_counts, :map, default: %{}

  def mount(_params, _session, socket) do
    if connected?(socket), do: send(self(), :load_data)
    {:ok, socket}
  end

  # Handles the loading of data when the `:load_data` message is received, when WebSockets are connected.
  # This includes subscribing to task updates and fetching tasks and status options asynchronously.
  def handle_info(:load_data, %{assigns: %{on_page_limit: on_page_limit} = assigns} = socket) do
    Tasks.subscribe()

    {tasks_task, total_tasks_task} = Utils.get_tasks_async_tasks(assigns)
    total_tasks = Task.await(total_tasks_task)
    status_options = Tasks.get_status_options()

    pending_value =
      status_options
      |> Enum.find(fn %{key: key} -> key == "pending" end)
      |> Map.get(:value)

    {:noreply,
     assign(
       socket,
       form: to_form(MyTask.changeset(%MyTask{}, %{"status_id" => pending_value})),
       default_form: to_form(MyTask.changeset(%MyTask{}, %{"status_id" => pending_value})),
       total_pages: ceil(total_tasks / on_page_limit),
       total_tasks: total_tasks,
       status_options: status_options,
       tasks: Task.await(tasks_task),
       loading: false
     )}
  end

  # Handles updates to the presence state for a specific topic when a presence event occurs.
  # When a user joins or leaves a task, this function is triggered to update the count of active viewers for that task.
  def handle_info(%{event: "presence_diff", topic: topic}, socket) do
    task_id = String.replace_prefix(topic, "task:", "") |> String.to_integer()
    viewers = TaskManagerWeb.Presence.list(topic) |> map_size()
    viewer_counts = Map.put(socket.assigns.viewer_counts || %{}, task_id, viewers)
    {:noreply, assign(socket, viewer_counts: viewer_counts)}
  end

  # Handles task deletion notifications from the `Tasks` module.
  # Updates the total task count, recalculates the total pages, and ensures the current page is valid.
  # ## Parameters
  #  - `{Tasks, [:task, :deleted], _}`: The message indicating a task has been deleted.
  #  - `socket`: The socket containing the current state.
  # ## Returns
  # An updated socket reflecting the changes after task deletion.
  def handle_info(
        {Tasks, [:task, :deleted], _},
        %{assigns: %{current_page: current_page, on_page_limit: on_page_limit} = assigns} = socket
      ) do
    total_tasks = Tasks.total_tasks(assigns)
    total_pages = ceil(total_tasks / on_page_limit)
    current_page = min(current_page, ceil(total_tasks / on_page_limit))

    new_socket = assign(socket, total_tasks: total_tasks, total_pages: total_pages, current_page: current_page)

    {:noreply, assign(socket, tasks: Tasks.get_tasks(new_socket.assigns))}
  end

  # Handles updates to tasks when a message from the `Tasks` module is received after task creation or update.
  # ## Parameters
  #  - `{Tasks, _, _}`: The message indicating some task-related update.
  #  - `socket`: The socket containing the current state.
  # ## Returns
  # An updated socket reflecting the changes after task updates.
  def handle_info(
        {Tasks, _, _},
        %{assigns: %{on_page_limit: on_page_limit} = assigns} = socket
      ) do
    {tasks_task, total_tasks_task} = Utils.get_tasks_async_tasks(assigns)
    total_tasks = Task.await(total_tasks_task)

    {:noreply,
     assign(socket,
       total_pages: ceil(total_tasks / on_page_limit),
       total_tasks: total_tasks,
       tasks: Task.await(tasks_task)
     )}
  end

  # Resets the state of the drawer component.
  # The updated socket after resetting the drawer state.
  def handle_info(:drawer_state_reset, socket),
    do: DrawerComponent.handle_event("drawer_state_reset", %{}, socket)

  def handle_event(event, params, socket)
      when event in ["validate", "create", "update", "delete", "pagination_click"],
      do: TasksHandleEvents.handle_event(event, params, socket)

  @doc """
  Handles various events related to tasks and UI interactions.

  This function delegates event handling to the appropriate component based on the event type.

  The updated socket after handling the event.
  """
  def handle_event(event, params, socket)
      when event in [
             "table_single_row_click_drawer",
             "table_sorting_click",
             "table_create_drawer"
           ],
      do: TasksTableComponent.handle_event(event, params, socket)

  def handle_event(event, params, socket)
      when event in [
             "drawer_confirm_delete_modal",
             "drawer_on_close"
           ],
      do: DrawerComponent.handle_event(event, params, socket)

  def handle_event("filters_click", params, socket),
    do: TasksFilterComponent.handle_event("filters_click", params, socket)

  def handle_event("modal_approve_set_close", params, socket),
    do: DeleteModalComponent.handle_event("modal_approve_set_close", params, socket)

  def render(assigns) do
    ~F"""
    {#if @loading}
      <div class="p-4 flex justify-center space-x-4">
        <Loader color="krillin" size="lg" />
      </div>
    {#else}
      <TasksTableComponent
        {=@tasks}
        {=@selected}
        {=@sort}
        {=@current_page}
        {=@total_tasks}
        {=@total_pages}
        {=@status_options}
        {=@status_selected}
        {=@filter_form}
        {=@current_user}
      />
    {/if}

    <DrawerComponent id="tasks_drawer" {=@drawer_title} {=@is_open}>
      <:inside_form>
        <TasksFormComponent
          {=@form}
          {=@status_options}
          {=@viewer_counts}
          disabled={@form.data.id && @form.data.user_id != @current_user.id}
        />
      </:inside_form>
    </DrawerComponent>

    <DeleteModalComponent title_message="Delete Task?" inner_message={@form.data.title} value={@form.data.id} />

    <SnackbarComponent id="snackbar_created" message={"Task #{@form.data.title} was created"} />
    <SnackbarComponent id="snackbar_updated" message={"Task #{@form.data.title} was updated"} />
    <SnackbarComponent id="snackbar_deleted" message={"Task #{@form.data.title} was deleted"} />
    """
  end
end
