defmodule TaskManagerWeb.TasksTableComponent do
  @moduledoc false
  use Surface.Component

  alias TaskManagerWeb.{
    PaginationComponent,
    TasksFilterComponent,
    Utils
  }

  alias TaskManager.Tasks.Task, as: MyTask
  alias TaskManager.Tasks

  alias Moon.Design.{
    Table,
    Table.Column,
    Button,
    Drawer
  }

  prop status_colors, :map,
    default: %{
      "pending" => "text-krillin",
      "in_progress" => "text-whis",
      "completed" => "text-roshi"
    }

  prop tasks, :list, required: true
  prop selected, :list, required: true
  prop sort, :keyword, required: true
  prop current_page, :integer, required: true
  prop total_tasks, :integer, required: true
  prop total_pages, :integer, required: true
  prop current_user, :map, required: true

  prop status_options, :list, required: true
  prop status_selected, :integer, required: true
  prop filter_form, :form, required: true

  def handle_event("table_create_drawer", _, %{assigns: %{default_form: default_form}} = socket) do
    Drawer.open("tasks_drawer")

    {:noreply,
     assign(socket,
       drawer_title: "New Task",
       is_open: true,
       form: default_form
     )}
  end

  def handle_event("table_single_row_click_drawer", %{"selected" => selected}, socket) do
    task = Utils.task_from_socket(selected, socket)

    Drawer.open("tasks_drawer")

    {
      :noreply,
      assign(socket,
        selected: [selected],
        is_open: true,
        drawer_title: "Task Information",
        form: to_form(MyTask.changeset(task))
      )
    }
  end

  def handle_event(
        "table_sorting_click",
        %{"sort-dir" => sort_dir, "sort-key" => sort_key},
        %{assigns: assigns} = socket
      ) do
    sort = ["#{sort_key}": sort_dir]
    {:noreply, assign(socket, sort: sort, tasks: Tasks.get_tasks(assigns, %{sort: sort}))}
  end

  def render(assigns) do
    ~F"""
    <div class="flex items-center">
      <Button on_click="table_create_drawer" class="bg-bulma ps-4 pe-4 py-5">Add New Task</Button>
      <h1 class="text-3xl font-bold flex-grow ml-4">Tasks</h1>
    </div>
    <div class="flex space-x-4 my-4">
      <TasksFilterComponent {=@status_selected} {=@status_options} {=@filter_form} />
    </div>
    <div>
      <PaginationComponent {=@total_pages} {=@current_page} {=@total_tasks} />
      <Table
        items={task <- @tasks}
        {=@sort}
        {=@selected}
        row_click="table_single_row_click_drawer"
        selected_bg="bg-krillin"
        is_zebra_style
        is_cell_border
        sorting_click="table_sorting_click"
        row_gap="border-spacing-y-1"
        class="bg-frieza-10 w-full block md:table"
      >
        <Column name="id" label="ID" sortable width="hidden 2xl:table-cell" class="w-1/8">
          {task.id}
        </Column>
        <Column name="title" width="hidden sm:table-cell" label="Title" sortable class="w-1/4">
          {Utils.string_slice(task.title, 50)}
        </Column>
        <Column name="description" width="hidden sm:table-cell" label="Description" class="w-1/2">
          {Utils.string_slice(task.description, 100)}
        </Column>
        <Column name="status_name" label="Status" width="hidden sm:table-cell" class="w-1/8">
          <span class={Map.get(@status_colors, task.status.name, "bg-gray-300")}>
            {task.status.name}
          </span>
        </Column>
        <Column name="user_email" label="User" width="hidden lg:table-cell" class="w-1/8">
          <span class={if task.user.id == @current_user.id, do: "text-chichi-60", else: "text-default"}>
            {hd(String.split(task.user.email, "@"))}
          </span>
        </Column>
        <Column name="inserted_at" label="Created at" sortable width="hidden 2xl:table-cell" class="w-1/8">
          {Utils.format_datetime_to_local(task.inserted_at)}
        </Column>
        <Column name="updated_at" label="Updated at" sortable width="hidden xl:table-cell" class="w-1/8">
          {Utils.format_datetime_to_local(task.updated_at)}
        </Column>
        <Column class="table-cell sm:hidden">
          #{task.id}: <span class="font-bold">{Utils.string_slice(task.title, 30)}</span>
          by <span class={"font-bold " <> if task.user.id == @current_user.id, do: "text-chichi-60", else: "text-default"}>
            {hd(String.split(task.user.email, "@"))}
          </span>
          <br>
          at {Utils.format_datetime_to_local(task.updated_at)}
          <br>
          {Utils.string_slice(task.description, 100)}
          <br>
          <span class={Map.get(@status_colors, task.status.name, "bg-gray-300")}>
            {task.status.name}
          </span>
        </Column>
      </Table>
    </div>
    """
  end
end
