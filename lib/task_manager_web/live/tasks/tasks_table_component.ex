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

  prop tasks, :list, required: true
  prop selected, :list, required: true
  prop sort, :keyword, required: true
  prop current_page, :integer, required: true
  prop total_tasks, :integer, required: true
  prop total_pages, :integer, required: true

  prop status_options, :list, required: true
  prop status_selected, :integer, required: true
  prop filter_form, :form, required: true

  def handle_event("table_create_drawer", _, %{assigns: %{default_form: default_form}} = socket) do
    Drawer.open("task_drawer")

    {:noreply,
     assign(socket,
       drawer_title: "New Task",
       is_open: true,
       form: default_form
     )}
  end

  def handle_event("table_single_row_click_drawer", %{"selected" => selected}, socket) do
    task = Utils.task_from_socket(selected, socket)

    Drawer.open("task_drawer")

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
        <Column name="id" label="ID" sortable class="w-1/8">
          {task.id}
        </Column>
        <Column name="title" label="Title" sortable class="w-1/8">
          {task.title}
        </Column>
        <Column name="description" label="Description" class="w-1/2">
          {task.description}
        </Column>
        <Column name="status" label="Status" class="w-1/8">
          {task.status.name}
        </Column>
        <Column name="author" label="Author" class="w-1/8">
          {hd(String.split(task.user.email, "@"))}
        </Column>
      </Table>
    </div>
    """
  end
end
