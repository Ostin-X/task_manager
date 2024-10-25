defmodule TaskManagerWeb.TasksFilterComponent do
  @moduledoc """
  A component for filtering tasks in the tasks page.

  This component includes a dropdown for selecting the task status
  and an input field for filtering tasks by username or email.
  It also provides a button to clear the current filters.

  ## Props

    - `status_options`: A list of available status options for filtering tasks.
      This prop is required.

    - `status_selected`: An integer representing the currently selected status.
      This prop is required.

    - `filter_form`: A form struct that manages the filtering inputs.
      This prop is required.

  ## Events

  The component handles the following events:

    - `"filters_click"`: Triggers when the filter is applied or cleared.
  """

  use Surface.Component

  alias Moon.Design.{Form, Button}
  alias TaskManagerWeb.{FilterChangeset, Utils}

  prop status_options, :list, required: true
  prop status_selected, :integer, required: true
  prop filter_form, :form, required: true

  @doc """
  Handles the event when a filter dropdown is clicked.

  Updates the filter form and assigns, fetches tasks based on
  the selected status and filter inputs, and updates the socket with
  the total tasks and pages.

  ## Params

    - `params`: The parameters from the dropdown click event including
      the selected status and filter text.

  """
  def handle_event(
        "filters_click",
        %{"filter_changeset" => %{"status_id" => status_id, "filter" => filter} = params},
        %{assigns: %{filter_form: %{data: filter_data}, on_page_limit: on_page_limit}} = socket
      ) do
    filter_form =
      filter_data
      |> FilterChangeset.filter_changeset(params)
      |> Map.put(:action, :insert)
      |> to_form

    status_id = String.to_integer(status_id)

    new_socket =
      assign(socket,
        filter_form: filter_form,
        status_selected: status_id,
        filter: filter
      )

    {tasks_task, total_tasks_task} = Utils.get_tasks_async_tasks(new_socket.assigns)
    total_tasks = Task.await(total_tasks_task)

    {:noreply,
     assign(new_socket,
       total_tasks: total_tasks,
       total_pages: ceil(total_tasks / on_page_limit),
       tasks: Task.await(tasks_task)
     )}
  end

  def handle_event(
        "filters_click",
        %{"value" => "clear"},
        %{assigns: %{on_page_limit: on_page_limit}} = socket
      ) do
    new_socket =
      assign(socket,
        filter_form: to_form(FilterChangeset.filter_changeset(%FilterChangeset{}, %{"status_id" => 0})),
        status_selected: 0,
        filter: ""
      )

    {tasks_task, total_tasks_task} = Utils.get_tasks_async_tasks(new_socket.assigns)
    total_tasks = Task.await(total_tasks_task)

    {:noreply,
     assign(new_socket,
       total_tasks: total_tasks,
       total_pages: ceil(total_tasks / on_page_limit),
       tasks: Task.await(tasks_task)
     )}
  end

  @doc """
  Renders the filter component.

  This includes a dropdown for selecting the task status, an input for filtering
  by username or email, and a button to clear filters.
  """
  def render(assigns) do
    ~F"""
    <div class="w-full flex flex-row gap-2 justify-between">
      <Form id="filter" class="w-full flex flex-row gap-2 items-center" for={@filter_form} change="filters_click">
        <Form.Field field={:status_id} class="w-1/3">
          <Form.Dropdown
            options={[%{value: 0, key: "All Tasks"} | @status_options]}
            prompt="Please select status"
            class="w-full"
          />
        </Form.Field>
        <Form.Field field={:filter} class="w-1/2">
          <Form.Input placeholder="Filter by username or email" class="w-full" opts={phx_debounce: "1000"} />
        </Form.Field>
        <Button
          class={"w-1/8 #{if @filter_form.params == %{"status_id" => 0}, do: "bg-trunks", else: "bg-bulma"}"}
          size="sm"
          on_click="filters_click"
          value="clear"
        >
          Clear filter
        </Button>
      </Form>
    </div>
    """
  end
end
