defmodule TaskManagerWeb.PaginationComponent do
  @moduledoc """
  A pagination component for navigating tasks in the tasks table.

  This component displays the current range of visible tasks and provides navigation
  controls for switching between pages. It integrates with the Moon Design System’s
  pagination UI elements and triggers updates on page changes.

  ## Props
    * `current_page` - The current page number being displayed.
    * `total_pages` - The total number of pages available.
    * `total_tasks` - The total count of tasks in the dataset.

  ## Events
    * `"pagination_click"` - Triggered when the user clicks to navigate to a different page.

  Usage example:
    ```
    <PaginationComponent
      current_page={@current_page}
      total_pages={@total_pages}
      total_tasks={@total_tasks}
    />
    ```
  """

  use Surface.Component

  alias Moon.Design.Pagination
  alias Moon.Icons.{ControlsChevronRight, ControlsChevronLeft}

  prop current_page, :integer, required: true
  prop total_pages, :integer, required: true
  prop total_tasks, :integer, required: true

  def render(assigns) do
    ~F"""
    <div class="flex items-center space-x-2 w-1/4">
      <span class="whitespace-nowrap text-sm">{(@current_page - 1) * 10 + min(1, @total_tasks)}-{min(@current_page * 10, @total_tasks)} of {@total_tasks}</span>
      {#case {@total_pages}}
        {#match {total_pages} when total_pages > 1}
          <Pagination id="with_buttons" {=total_pages} value={@current_page} on_change="pagination_click">
            <Pagination.PrevButton class="border-none">
              <ControlsChevronLeft class="text-moon-24 rtl:rotate-180" />
            </Pagination.PrevButton>
            <Pagination.Pages selected_bg_color="bg-frieza-10" />
            <Pagination.NextButton class="border-none">
              <ControlsChevronRight class="text-moon-24 rtl:rotate-180" />
            </Pagination.NextButton>
          </Pagination>
        {#match _}
      {/case}
    </div>
    """
  end
end
