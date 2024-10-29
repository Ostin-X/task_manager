defmodule TaskManagerWeb.PollingLive do
  use TaskManagerWeb, :surface_live_view

  alias Moon.Design.Drawer
  alias Moon.Design.Button
  alias Moon.Icon
  alias Moon.Design.Carousel
  alias Moon.Design.Table
  alias Moon.Design.Table.Column
  alias Moon.Components.Renderers.Datetime

  data(models, :list,
    default:
      Enum.map(1..5, fn x ->
        %{
          id: x,
          name: "Name #{x}",
          created_at: DateTime.utc_now()
        }
      end)
  )

  defp get_items() do
    Enum.map(TaskManager.Tasks.list_statuses(), & &1.name)
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~F"""
    <div class="relative w-full">
      <Carousel id="default" value={6} step={5} class="w-full">
        <Carousel.LeftArrow>
          <Icon name="controls_chevron_left_small" class="text-moon-24" />
        </Carousel.LeftArrow>
        <Carousel.Reel>
          <Carousel.Item class="bg-trunks block" :for={item <- get_items()}>
            <div class="flex justify-center items-center p-3">
              <h1 class="text-2xl">{item}</h1>
            </div>
            <div>
              <Table items={model <- @models} selected={nil}>
                <Column name="id" label="ID">
                  {model.id}
                </Column>
                <Column name="name" label="First Name">
                  {model.name}
                </Column>
                <Column name="created_at" label="Created at">
                  <Datetime value={model.created_at} />
                </Column>
              </Table>
              <Button variant="outline" on_click="set_open" value={item}>
                Show Drawer with Backdrop
              </Button>
              <Drawer id={"backdrop_drawer #{item}"}>
                <Drawer.Panel>
                  <div class="flex justify-between items-center p-3 border-b border-trunks">
                    <p>Drawer with Backdrop</p>
                  </div>
                  <div class="p-3">Drawer content</div>
                </Drawer.Panel>
                <Drawer.Backdrop />
              </Drawer>
            </div>
          </Carousel.Item>
          <Carousel.Indicator />
        </Carousel.Reel>
        <Carousel.RightArrow>
          <Icon name="controls_chevron_right_small" class="text-moon-24" />
        </Carousel.RightArrow>
      </Carousel>
    </div>
    """
  end

  def handle_event("set_open", %{"value" => value}, socket) do
    Drawer.open("backdrop_drawer #{value}")
    {:noreply, socket}
  end
end
