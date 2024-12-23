defmodule TaskManagerWeb.TasksFormComponent do
  @moduledoc """
  A form component for creating and updating tasks using the Moon Design Form system.

  The `TasksFormComponent` is a reusable component designed to handle task creation and updates.
  It displays a form with fields for entering a task's title, description, and status.
  Depending on the task's existence, the form dynamically adjusts to either create a new task or update an existing one.
  The `disabled` property ensures that only the author of the task has permission to modify or delete it,
  while other users can view the task details in a read-only mode.

  ## Usage

  To use this component, provide a changeset (`form`), a list of status options (`status_options`), and an integer (`disabled`) indicating the form's state.
  The form will display input fields and buttons according to these parameters.

  Example:

      <TasksFormComponent
        form={@task_changeset}
        status_options={@status_options}
        disabled={@form_disabled}
      />

  """
  use Surface.Component

  alias Moon.Design.{Form, Button}

  alias TaskManagerWeb.Utils

  prop form, :changeset, required: true
  prop status_options, :list, required: true
  prop disabled, :integer, required: true
  prop viewer_counts, :map, default: %{}

  def render(assigns) do
    ~F"""
    <Form
      id="form"
      for={@form}
      change="validate"
      submit={if @form.data.id, do: "update", else: "create"}
      class="bg-frieza-10 rounded-xl"
    >
      <div class="ml-2 text-sm" :if={@form.data.id}>
        {Utils.viewers_text(Map.get(@viewer_counts, @form.data.id, 0))}
      </div>
      <Form.Field :if={@form.data.id} label="ID">
        <Form.Input field={:id} readonly />
      </Form.Field>
      <Form.Field field={:title} label="Title" has_error_icon>
        <Form.Input placeholder="Please enter title" {=@disabled} />
      </Form.Field>
      <Form.Field field={:description} label="Description" has_error_icon>
        <Form.TextArea placeholder="Please enter description" {=@disabled} rows={10} />
      </Form.Field>
      <Form.Field field={:status_id} label="Status">
        <Form.Dropdown options={@status_options} prompt="Please select status" {=@disabled} />
      </Form.Field>
      {#if @form.data.id}
        <Form.Field field={:user_email}>
          <Form.Input placeholder={String.split(@form.data.user.email, "@") |> Enum.at(0)} disabled />
        </Form.Field>
        <Form.Field field={:inserted_at}>
          <Form.Input placeholder={@form.data.inserted_at} disabled />
        </Form.Field>
        <Form.Field field={:updated_at}>
          <Form.Input placeholder={@form.data.updated_at} disabled />
        </Form.Field>
        <div class="p-4 flex justify-center space-x-4">
          {#if !@disabled}
            <Button type="submit" class="bg-popo" disabled={@form.params == %{} || @form.errors != []}>Update</Button>
            <Button on_click="drawer_confirm_delete_modal" value={@form.data.id} class="ms-1 bg-dodoria">Delete</Button>
          {/if}
        </div>
      {#else}
        <div class="p-4 flex justify-center space-x-4">
          <Button type="submit" class="bg-popo" disabled={@form.params == %{} || @form.errors != []}>Create</Button>
        </div>
      {/if}
    </Form>
    """
  end
end
