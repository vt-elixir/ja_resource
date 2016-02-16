defmodule JaResource.UpdateTest do
  use ExUnit.Case
  use Plug.Test

  defmodule DefaultController do
    use Phoenix.Controller
    use JaResource.Update
    def repo, do: JaResourceTest.Repo
    def model, do: JaResourceTest.Post
  end

  defmodule CustomController do
    use Phoenix.Controller
    use JaResource.Update
    def repo, do: JaResourceTest.Repo
    def model, do: JaResourceTest.Post
    def handle_update(c, nil, _attrs), do: send_resp(c, 420, "")
    def handle_update(_c, _post, %{"title" => "valid"}) do
      {:ok, %JaResourceTest.Post{title: "valid"}}
    end
    def handle_update(_c, _post, %{"title" => "invalid"}) do
      {:error, [title: "is invalid"]}
    end
  end

  test "default implementation renders 404 if record not found" do
    conn = prep_conn(:put, "/posts/404")
    response = DefaultController.update(conn, ja_attrs(404, %{"title" => "valid"}))
    assert response.status == 404
  end

  test "default implementation renders 200 if valid" do
    {:ok, post} = JaResourceTest.Repo.insert(%JaResourceTest.Post{id: 200})
    conn = prep_conn(:put, "/posts/#{post.id}")
    response = DefaultController.update(conn, ja_attrs(post.id, %{"title" => "valid"}))
    assert response.status == 200
  end

  test "default implementation renders 422 if invalid" do
    {:ok, post} = JaResourceTest.Repo.insert(%JaResourceTest.Post{id: 422})
    conn = prep_conn(:put, "/posts/#{post.id}")
    response = DefaultController.update(conn, ja_attrs(post.id, %{"title" => "invalid"}))
    assert response.status == 422
  end

  test "custom implementation renders conn if returned" do
    conn = prep_conn(:put, "/posts/420")
    response = CustomController.update(conn, ja_attrs(420, %{"title" => "valid"}))
    assert response.status == 420
  end

  test "custom implementation renders 200 if valid" do
    {:ok, post} = JaResourceTest.Repo.insert(%JaResourceTest.Post{id: 200})
    conn = prep_conn(:put, "/posts/#{post.id}")
    response = CustomController.update(conn, ja_attrs(post.id, %{"title" => "valid"}))
    assert response.status == 200
  end

  test "custom implementation renders 422 if invalid" do
    {:ok, post} = JaResourceTest.Repo.insert(%JaResourceTest.Post{id: 422})
    conn = prep_conn(:put, "/posts/#{post.id}")
    response = CustomController.update(conn, ja_attrs(post.id, %{"title" => "invalid"}))
    assert response.status == 422
  end


  def prep_conn(method, path, params \\ %{}) do
    params = Map.merge(params, %{"_format" => "json"})
    conn(method, path, params)
      |> fetch_query_params
      |> Phoenix.Controller.put_view(JaResourceTest.PostView)
  end

  defp ja_attrs(id, attrs) do
    %{
      "id" => id,
      "type" => "post",
      "data" => %{
        "attributes" => attrs
      }
    }
  end
end
