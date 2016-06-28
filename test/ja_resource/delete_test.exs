defmodule JaResource.DeleteTest do
  use ExUnit.Case
  use Plug.Test
  alias JaResource.Delete

  defmodule DefaultController do
    use Phoenix.Controller
    use JaResource.Delete
    def repo, do: JaResourceTest.Repo
    def model, do: JaResourceTest.Post
  end

  defmodule CustomController do
    use Phoenix.Controller
    use JaResource.Delete
    def repo, do: JaResourceTest.Repo
    def model, do: JaResourceTest.Post
    def handle_delete(conn, record) do
      case conn.assigns[:user] do
        %{is_admin: true} -> super(conn, record)
        _                 -> send_resp(conn, 401, "ah ah ah")
      end
    end
  end

  test "default implementation renders 404 if record not found" do
    conn = prep_conn(:delete, "/posts/404", %{"id" => 404})
    response = Delete.call(DefaultController, conn)
    assert response.status == 404
  end

  test "default implementation returns 204 if record found" do
    {:ok, post} = JaResourceTest.Repo.insert(%JaResourceTest.Post{id: 200})
    conn = prep_conn(:delete, "/posts/#{post.id}", %{"id" => post.id})
    response = Delete.call(DefaultController, conn)
    assert response.status == 204
  end

  test "custom implementation retuns 401 if not admin" do
    {:ok, post} = JaResourceTest.Repo.insert(%JaResourceTest.Post{id: 401})
    conn = prep_conn(:delete, "/posts/#{post.id}", %{"id" => post.id})
    response = Delete.call(CustomController, conn)
    assert response.status == 401
  end

  test "custom implementation retuns 404 if no model" do
    conn = prep_conn(:delete, "/posts/404", %{"id" => 404})
            |> assign(:user, %{is_admin: true})
    response = Delete.call(CustomController, conn)
    assert response.status == 404
  end

  test "custom implementation retuns 204 if record found" do
    {:ok, post} = JaResourceTest.Repo.insert(%JaResourceTest.Post{id: 200})
    conn = prep_conn(:delete, "/posts/#{post.id}", %{"id" => post.id})
            |> assign(:user, %{is_admin: true})
    response = Delete.call(DefaultController, conn)
    assert response.status == 204
  end

  def prep_conn(method, path, params \\ %{}) do
    params = Map.merge(params, %{"_format" => "json"})
    conn(method, path, params)
      |> fetch_query_params
      |> Phoenix.Controller.put_view(JaResourceTest.PostView)
  end
end
