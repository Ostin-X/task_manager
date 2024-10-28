defmodule TaskManagerWeb.DrawerComponent do
  @moduledoc """
  A reusable component for rendering a drawer panel with a title and customizable content.

  The `DrawerComponent` is a UI element that slides in from the side of the screen, showing additional information or forms.
  It uses the Moon Design System to style the drawer and its components.

  ## Usage

  To use this component, specify a unique `id`, the `is_open` state to control visibility, and a `drawer_title` for the header.
  The content inside the drawer can be customized using the `inside_form` slot.

  Example:

      <DrawerComponent
        id="tasks_drawer"
        is_open={@is_open}
        drawer_title="Task Details"
      >
        <#inside_form>
          <!-- Custom form or content here -->
        </#inside_form>
      </DrawerComponent>
  """
  use Surface.Component

  alias Moon.Design.{Drawer, Modal}

  prop id, :string, required: true
  prop is_open, :boolean, required: true
  prop drawer_title, :string, required: true

  slot inside_form

  # Event handler for closing the drawer.
  # This function handles the `"drawer_on_close"` event, which is triggered when
  # the drawer close button is clicked. The drawer closes and a message to reset
  # its state is sent with a 300 ms delay.
  def handle_event("drawer_on_close", _, socket) do
    Drawer.close("tasks_drawer")
    Process.send_after(self(), :drawer_state_reset, 300)
    {:noreply, socket}
  end

  # Resets the drawer's state after closing.
  # This function is called when the `:drawer_state_reset` message is received.
  # It resets the drawer properties, clearing any assigned values such as the form
  # and drawer title, and updates the `is_open` state to `false`.
  def handle_event("drawer_state_reset", _, %{assigns: %{selected: [selected]}} = socket) do
    # TODO: This BS breaks the drawer animation!!!!
    TaskManagerWeb.Presence.untrack(self(), "task:#{selected}", socket.id)

    {:noreply,
     assign(socket,
       selected: [],
       is_open: false,
       drawer_title: ""
     )}
  end

  # Opens a confirmation modal upon delete action.
  # This function handles the `"drawer_confirm_delete_modal"` event, which closes the drawer
  # and opens a delete confirmation modal (with ID `"approve_delete"`).
  def handle_event("drawer_confirm_delete_modal", _, socket) do
    handle_event("drawer_state_reset", nil, socket)

    Modal.open("approve_delete")
    {:noreply, socket}
  end

  def render(assigns) do
    ~F"""
    <Drawer {=@id} {=@is_open} on_close="drawer_on_close">
      <Drawer.Panel>
        <div class="text-center bg-zeno antialiased theme-moon-light">
          <h1 class="text-3xl font-bold">{@drawer_title}</h1>
        </div>
        <div>
          <#slot {@inside_form} />
        </div>
      </Drawer.Panel>
      <Drawer.Backdrop />
    </Drawer>
    """
  end
end
