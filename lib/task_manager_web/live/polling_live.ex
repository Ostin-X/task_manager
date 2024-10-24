defmodule TaskManagerWeb.PollingLive do
  use TaskManagerWeb, :surface_live_view

  alias Moon.Design.Drawer
  alias Moon.Design.Button

  def mount(_params, session, socket) do

    statuses = Enum.map(TaskManager.Tasks.list_statuses(), & &1.name) |> Enum.join(", ")
    |> IO.inspect
#    current_user = get_current_user(session)

    #    IO.inspect(session)
#    IO.inspect(session, label: "session")
#    IO.inspect(socket.assigns, label: "assigns")
#    IO.inspect(socket.assigns.current_user, label: "assigns")
#    {:ok, socket}
    {:ok, assign(socket, statuses: statuses)}
  end

  def render(assigns) do
    ~F"""
    <div>
      <h1 class="text-2xl">{@statuses}</h1>
      <Button variant="outline" on_click="set_open">
        Show Drawer with Backdrop
      </Button>
      <Drawer id="backdrop_drawer">
        <Drawer.Panel>
          <div class="flex justify-between items-center p-3 border-b border-trunks">
            <p>Drawer with Backdrop</p>
          </div>
          <div class="p-3">Drawer content</div>
        </Drawer.Panel>
        <Drawer.Backdrop />
      </Drawer>
    </div>
    """
  end

  def handle_event("set_open", _, socket) do
    Drawer.open("backdrop_drawer")
    {:noreply, socket}
  end
end
