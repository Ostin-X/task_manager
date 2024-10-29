defmodule TaskManagerWeb.SnackbarComponent do
  @moduledoc """
  A simple component for displaying temporary notification messages using the Moon Design Snackbar.

  The `SnackbarComponent` provides a brief, non-intrusive way to inform users of changes, actions, or alerts.
  Positioned at the top-center of the screen, the snackbar displays a single message at a time.

  ## Usage

  To use the component, provide a unique `id` and a `message` string. The message will be displayed within the snackbar.
  You can control the snackbar’s visibility from the parent component.

  Example:

      <SnackbarComponent id="task_notification" message="Task completed successfully!" />
  """
  use Surface.Component

  alias Moon.Design.Snackbar

  prop id, :string
  prop message, :string

  def render(assigns) do
    ~F"""
    <Snackbar {=@id} position="top-center">
      <Snackbar.Content>
        <Snackbar.Message>{@message}</Snackbar.Message>
      </Snackbar.Content>
    </Snackbar>
    """
  end
end
