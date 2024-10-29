defmodule TaskManagerWeb.TasksMainPageLiveTest do
  use TaskManagerWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import TaskManager.TasksFixtures

  @table_id "tasks_table"
  @form_id "form"

  describe "Tasks redirect when not logged in" do
    setup [:setup_database]

    test "redirects if user is not logged in", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/")
      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log_in"
      assert %{"error" => "You must log in to access this page."} = flash
    end
  end

  describe "Tasks page" do
    setup [:setup_database, :login_user1]

    defp login_user1(%{conn: conn, user1: user1} = context) do
      conn = log_in_user(conn, user1)
      {:ok, Map.put(context, :conn, conn)}
    end

    test "renders basic HTML", %{conn: conn, user1: user1} do
      {:ok, _view, html} = live(conn, ~p"/")

      assert html =~ user1.email
      assert html =~ "Delete Task"
      refute html =~ "Tasks"
    end

    test "renders tasks page", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      assert has_element?(view, "table")

      rendered_html = render(view)
      assert rendered_html =~ "Tasks"
      assert rendered_html =~ "some title 1"
      assert rendered_html =~ "some title 10"
      refute rendered_html =~ "some title 11"
    end

    test "navigates to the next page", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view
      |> element("button[phx-click=\"pagination_click\"][value=\"2\"].text-bulma")
      |> render_click()

      assert render(view) =~ "11-20"

      view
      |> element("button[phx-click=\"pagination_click\"][value=\"1\"].text-bulma")
      |> render_click()

      assert render(view) =~ "1-10"
    end

    test "update task event", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      refute render(view) =~ "testKey"

      view
      |> element("##{@table_id}-row-0")
      |> render_click()

      assert render(view) =~ "Task Information"

      view
      |> form("form##{@form_id}",
        task: %{
          title: "testKey",
          description: "Test Label"
        }
      )
      |> render_change()

      view |> form("form##{@form_id}") |> render_submit()

      Process.sleep(500)

      refute render(view) =~ "Task Information"
      assert render(view) =~ "Tasks"
      assert render(view) =~ "testKey"
      assert render(view) =~ "Task  was updated"
    end

    test "create task event", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      refute render(view) =~ "testKey"

      view
      |> element("#table_create_button")
      |> render_click()

      assert render(view) =~ "New Task"

      view
      |> form("form##{@form_id}",
        task: %{
          title: "testKey",
          description: "Test Label"
        }
      )
      |> render_change()

      view |> form("form##{@form_id}") |> render_submit()

      Process.sleep(500)

      refute render(view) =~ "Task Information"
      assert render(view) =~ "Tasks"
      assert render(view) =~ "Task  was created"
    end

    test "delete task event", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      assert render(view) =~ "some title 1"

      view
      |> element("##{@table_id}-row-0")
      |> render_click()

      assert render(view) =~ "Task Information"

      view
      |> element("[phx-click='drawer_confirm_delete_modal']")
      |> render_click()

      assert render(view) =~ "Delete Task?"
      assert render(view) =~ "some title 1"

      view
      |> element("[phx-click='delete']")
      |> render_click()

      Process.sleep(1000)

#      refute render(view) =~ "Task Information"
      assert render(view) =~ "Tasks"
      assert render(view) =~ "Task some title 1 was deleted"
    end
  end
end
