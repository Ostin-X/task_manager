defmodule TaskManagerWeb.PaginationComponent do
  @moduledoc """
  Pagination component for tasks page table
  """
  use Surface.Component

  alias Moon.Design.Pagination
  alias Moon.Icons.{ControlsChevronRight, ControlsChevronLeft}

  prop current_page, :integer
  prop total_pages, :integer

  def render(assigns) do
    ~F"""
    {#case {@total_pages}}
      {#match {total_pages} when total_pages > 1}
        <Pagination id="with_buttons" {=total_pages} value={@current_page} on_change="pagination_click">
          <Pagination.PrevButton class="border-none">
            <ControlsChevronLeft class="text-moon-24 rtl:rotate-180" />
          </Pagination.PrevButton>
          <Pagination.Pages selected_bg_color="bg-frieza-10" /> <Pagination.NextButton class="border-none">
            <ControlsChevronRight class="text-moon-24 rtl:rotate-180" />
          </Pagination.NextButton>
        </Pagination>
      {#match _}{/case}
    """
  end
end
