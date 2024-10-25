defmodule TaskManagerWeb.TasksLive do
  @moduledoc false
  use TaskManagerWeb, :surface_live_view

  alias Moon.Design.{Loader}

  alias TaskManager.Tasks.Task, as: MyTask
  alias TaskManager.Tasks

  alias TaskManagerWeb.{
    TasksHandleEvents,
    TasksTableComponent,
    #      AdminDrawerComponent,
    #      SnackbarComponent,
    #      DeleteModalComponent,
    TasksFilterComponent,
    #      AdminUsersFormComponent,
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

  #  data drawer_title, :string, default: nil
  data is_open, :boolean, default: false
  data form, :form, default: to_form(MyTask.changeset(%MyTask{}))
  data default_form, :form, default: to_form(MyTask.changeset(%MyTask{}))

  def mount(_params, _session, socket) do
    if connected?(socket), do: send(self(), :load_data)
    {:ok, socket}
  end

  def handle_info(:load_data, %{assigns: %{on_page_limit: on_page_limit} = assigns} = socket) do
    Tasks.subscribe()

    {tasks_task, total_tasks_task} = Utils.get_tasks_async_tasks(assigns)
    total_tasks = Task.await(total_tasks_task)
    status_task = Task.async(fn -> Tasks.get_status_options() end)

    {:noreply,
     assign(socket,
       total_pages: ceil(total_tasks / on_page_limit),
       total_tasks: total_tasks,
       status_options: Task.await(status_task),
       tasks: Task.await(tasks_task),
       loading: false
     )}
  end

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
       users: Task.await(tasks_task)
     )}
  end

  #  def handle_info(:drawer_state_reset, socket),
  #    do: AdminDrawerComponent.handle_event("drawer_state_reset", %{}, socket)

  def handle_event(event, params, socket)
      when event in ["validate", "update", "delete", "pagination_click"],
      do: TasksHandleEvents.handle_event(event, params, socket)

  def handle_event(event, params, socket)
      when event in [
             "table_single_row_click_drawer",
             "table_sorting_click"
           ],
      do: TasksTableComponent.handle_event(event, params, socket)

  #  def handle_event(event, params, socket)
  #      when event in [
  #             "drawer_confirm_delete_modal",
  #             "drawer_on_close"
  #           ],
  #      do: AdminDrawerComponent.handle_event(event, params, socket)

  def handle_event("filters_click", params, socket),
    do: TasksFilterComponent.handle_event("filters_click", params, socket)

  #  def handle_event("modal_approve_set_close", params, socket),
  #    do: DeleteModalComponent.handle_event("modal_approve_set_close", params, socket)

  #      <SnackbarComponent id="snackbar_forbidden" message="Forbidden" />
  #      <SnackbarComponent id="snackbar_updated" message={"User #{@form.data.username} was updated"} />
  #      <SnackbarComponent id="snackbar_deleted" message={"User #{@form.data.username} was deleted"} />
  #      <AdminDrawerComponent id="admin_drawer" {=@drawer_title} {=@is_open}>
  #        <:inside_form>
  #          <AdminUsersFormComponent
  #            {=@form}
  #            operator_options={[%{value: 0, key: "No operator"} | tl(@operator_options)]}
  #            {=@role_options}
  #            {=@operator_locked}
  #            {=@current_user}
  #          />
  #        </:inside_form>
  #      </AdminDrawerComponent>
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
      />
    {/if}
    """
  end
end

#      <div>
#        <DeleteModalComponent
#          title_message="Delete User?"
#          inner_message={@form.data.username}
#          value={@form.data.id}
#        />
#      </div>
