defmodule TaskManagerWeb.PopulateLive do
  use TaskManagerWeb, :surface_live_view

  alias Moon.Design.Drawer
  alias Moon.Design.Button
  alias Moon.Icon
  alias Moon.Design.Carousel
  alias Moon.Design.Table
  alias Moon.Design.Table.Column
  alias Moon.Components.Renderers.Datetime

  def handle_event("populate", _, socket) do
    TaskManagerWeb.GlobalSetup.run()

    {:noreply, socket}
  end

  def render(assigns) do
    ~F"""
    <div class="relative w-full">
      <Button animation="pulse" on_click="populate">Pulse</Button>
    </div>
    """
  end
end
