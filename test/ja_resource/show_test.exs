defmodule JaResource.ShowTest do
  use ExUnit.Case
  use Plug.Test

  defmodule DefaultController do
    use Phoenix.Controller
    use JaResource.Show
    def repo, do: JaResourceTest.Repo
    def model, do: JaResourceTest.Post
  end

  defmodule CustomController do
    use Phoenix.Controller
    use JaResource.Show
    def repo, do: JaResourceTest.Repo
    def handle_show(conn, _id), do: send_resp(conn, 401, "")
  end

  test "default implementation return 404 if not found" do
    conn = prep_conn(:get, "/posts/404")
    response = DefaultController.show(conn, %{"id" => 404})
    assert response.status == 404
  end

  test "default implementation return 200 if found" do
    conn = prep_conn(:get, "/posts/200")
    JaResourceTest.Repo.insert(%JaResourceTest.Post{id: 200})
    response = DefaultController.show(conn, %{"id" => 200})
    assert response.status == 200
  end

  test "custom implementation return 401" do
    conn = prep_conn(:get, "/posts/401")
    response = CustomController.show(conn, %{"id" => 401})
    assert response.status == 401
  end

  def prep_conn(method, path, params \\ %{}) do
    params = Map.merge(params, %{"_format" => "json"})
    conn(method, path, params)
      |> fetch_query_params
      |> Phoenix.Controller.put_view(JaResourceTest.PostView)
  end
end
