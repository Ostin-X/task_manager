defmodule TaskManagerWeb.TasksMainPageLiveTest do
  use TaskManagerWeb.ConnCase, async: true

  alias TaskManager.Accounts
  alias TaskManager.Tasks
  import Phoenix.LiveViewTest
  import TaskManager.AccountsFixtures
  import TaskManager.TasksFixtures

  describe "Tasks page" do
    setup %{conn: conn} do
      user1 = user_fixture()
      user2 = user_fixture()
      users = [user1, user2]

      status1 = status_fixture()
      status2 = status_fixture()
      statuses = [status1, status2]

      conn = log_in_user(conn, user1)

      # Create sample tasks for testing
      create_tasks_fixture(%{users: users, statuses: statuses, number: 30})

      %{conn: conn, user1: user1, user2: user2, status1: status1, status2: status2}
    end

    test "renders tasks page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/tasks")

      assert html =~ "Your Tasks"
      assert html =~ "Create Task"
    end

    #    test "displays tasks paginated (10 per page)", %{conn: conn} do
    #      {:ok, lv, _html} = live(conn, ~p"/tasks")
    #
    #      # Assert that the first page shows 10 tasks
    #      assert length(lv.assigns.tasks) == 10
    #
    #      # Assert that pagination links exist
    #      assert html =~ "Next"
    #      assert html =~ "Previous"
    #    end
    #
    #    test "navigates to the next page", %{conn: conn} do
    #      {:ok, lv, _html} = live(conn, ~p"/tasks")
    #
    #      # Click the next page button
    #      lv
    #      |> element("a[phx-click=\"next\"]")
    #      |> render_click()
    #
    #      # Assert that we are now on the second page
    #      assert length(lv.assigns.tasks) == 10
    #      # Optionally, you can check if tasks have changed
    #    end
    #
    #    test "navigates to the previous page", %{conn: conn} do
    #      {:ok, lv, _html} = live(conn, ~p"/tasks")
    #
    #      # Go to the next page first
    #      lv
    #      |> element("a[phx-click=\"next\"]")
    #      |> render_click()
    #
    #      # Click the previous page button
    #      lv
    #      |> element("a[phx-click=\"previous\"]")
    #      |> render_click()
    #
    #      # Assert that we are back on the first page
    #      assert length(lv.assigns.tasks) == 10
    #    end
    #
    #    test "redirects if user is not logged in", %{conn: conn} do
    #      conn = build_conn()
    #      assert {:error, redirect} = live(conn, ~p"/tasks")
    #
    #      assert {:redirect, %{to: path, flash: flash}} = redirect
    #      assert path == ~p"/users/log_in"
    #      assert %{"error" => "You must log in to access this page."} = flash
    #    end
  end
end
