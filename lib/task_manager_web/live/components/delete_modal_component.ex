defmodule TaskManagerWeb.DeleteModalComponent do
  @moduledoc """
  A component for rendering a confirmation modal for delete actions.

  This component displays a modal dialog with a title, an inner message,
  and two buttons: a delete confirmation button and a cancel button.
  It uses Moon Design System components for consistent styling.

  ## Usage

  To display this modal, provide `title_message`, `inner_message`, and `value`
  (typically an identifier for the item to be deleted). When the delete button
  is clicked, it triggers an external `"delete"` event, passing `value` as the
  parameter. Clicking the cancel button will close the modal without further action.

  Example:

      <DeleteModalComponent
        title_message="Confirm Delete"
        inner_message="Are you sure you want to delete this item?"
        value="item-id"
      />
  """
  use Surface.Component

  alias Moon.Design.{Modal, Button}

  prop title_message, :string, required: true
  prop inner_message, :string, required: true
  prop value, :string, required: true

  def handle_event("modal_approve_set_close", _, socket) do
    Modal.close("approve_delete")
    {:noreply, assign(socket, selected: [])}
  end

  def render(assigns) do
    ~F"""
    <Modal id="approve_delete">
      <Modal.Backdrop /> <Modal.Panel>
        <div class="p-4 border-b-2 border-beerus">
          <h3 class="text-moon-18 text-bulma font-medium">
            {@title_message}
          </h3>
        </div>
        <div class="p-4">
          <p class="text-moon-16 text-trunks">
            {@inner_message}
          </p>
        </div>
        <div class="p-4 border-t-2 border-beerus flex justify-center space-x-4">
          <Button on_click="delete" {=@value} animation="error">DELETE!</Button>
          <Button on_click="modal_approve_set_close">Cancel</Button>
        </div>
      </Modal.Panel>
    </Modal>
    """
  end
end
