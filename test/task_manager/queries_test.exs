defmodule TaskManager.Tasks.QueriesTest do
  use TaskManager.DataCase

  import TaskManager.AccountsFixtures
  import TaskManager.TasksFixtures
  alias TaskManager.Tasks.Queries

  describe "get_tasks_query/1" do
    setup do
      user1 = user_fixture()
      user2 = user_fixture()
      user3 = user_fixture()
      users = [user1, user2, user3]
      statuses = create_statuses_fixture(%{number: 3})
      tasks = create_tasks_fixture(%{users: users, statuses: statuses, number: 15})

      %{tasks: tasks, users: users, statuses: statuses}
    end

    test "returns tasks based on filter and sorting", %{} do
      filter = "some title 1"
      good_task1 = "some title 11"
      good_task2 = "some title 12"
      bad_task = "some title 5"
      sort = [{:title, "ASC"}]

      params = %{
        sort: sort,
        current_page: 1,
        on_page_limit: 10,
        filter: filter,
        # No specific status filter
        status_selected: 0
      }

      query = Queries.get_tasks_query(params)
      results = Repo.all(query)

      assert length(results) == 7
      assert Enum.any?(results, fn task -> task.title == filter end)
      assert Enum.any?(results, fn task -> task.title == good_task1 end)
      assert Enum.any?(results, fn task -> task.title == good_task2 end)
      refute Enum.any?(results, fn task -> task.title == bad_task end)
    end

    test "returns paginated tasks", %{} do
      good_task1 = "some title 1"
      good_task2 = "some title 7"
      bad_task = "some title 8"

      params = %{
        sort: [{:id, "ASC"}],
        current_page: 1,
        on_page_limit: 7,
        filter: "",
        status_selected: 0
      }

      query = Queries.get_tasks_query(params)
      results = Repo.all(query)

      assert length(results) == 7
      assert Enum.any?(results, fn task -> task.title == good_task1 end)
      assert Enum.any?(results, fn task -> task.title == good_task2 end)
      refute Enum.any?(results, fn task -> task.title == bad_task end)
    end

    test "counts total tasks with specific status", %{statuses: statuses} do
      status_id = Enum.at(statuses, 1).id

      params = %{
        filter: "",
        status_selected: status_id
      }

      tasks_query = Queries.base_filtered_tasks_query(params)
      tasks = Repo.all(tasks_query)
      total = Repo.aggregate(tasks_query, :count, :id)

      assert total >= 0
      assert Enum.all?(tasks, fn task -> task.status_id == status_id end)
      refute Enum.any?(tasks, fn task -> task.status_id == status_id + 1 end)
      refute Enum.any?(tasks, fn task -> task.status_id == status_id - 1 end)
    end

    test "returns no tasks when there are no matches", %{} do
      params = %{
        sort: [{:id, "ASC"}],
        current_page: 1,
        on_page_limit: 7,
        filter: "nonexistent title",
        status_selected: 0
      }

      query = Queries.get_tasks_query(params)
      results = Repo.all(query)

      assert Enum.empty?(results)
    end

    test "returns tasks filtered by both status and title", %{statuses: statuses, users: users} do
      status_id = Enum.at(statuses, 0).id
      title_filter = "some title 1"
      new_tile = "some title 111"
      user_id = Enum.at(users, 0).id
      new_task = task_fixture(%{title: new_tile, status_id: status_id, user_id: user_id})

      params = %{
        sort: [{:id, "ASC"}],
        current_page: 1,
        on_page_limit: 20,
        filter: title_filter,
        status_selected: status_id
      }

      query = Queries.get_tasks_query(params)
      results = Repo.all(query)

      assert Enum.all?(results, fn task -> task.status_id == status_id end)
      assert Enum.any?(results, fn task -> task.id == new_task.id end)
    end
  end
end
