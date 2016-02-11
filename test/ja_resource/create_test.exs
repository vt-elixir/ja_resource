defmodule JaResource.CreateTest do
  use ExUnit.Case
  use Plug.Test

  defmodule DefaultController do
    use Phoenix.Controller
    use JaResource.Create
    def repo, do: JaResourceTest.Repo
    def model, do: JaResourceTest.Post
  end

  defmodule ProtectedController do
    use Phoenix.Controller
    use JaResource.Create
    def repo, do: JaResourceTest.Repo
    def handle_create(conn, _attrs), do: send_resp(conn, 401, "")
  end

  defmodule CustomController do
    use Phoenix.Controller
    use JaResource.Create
    def repo, do: JaResourceTest.Repo
    def handle_create(_c, %{"title" => "valid"}), 
      do: {:ok, %JaResourceTest.Post{title: "valid"}}
    def handle_create(_c, %{"title" => "invalid"}), 
      do: {:error, [title: "is invalid"]}
  end

  test "default implimentation renders 201 if valid" do
    conn = prep_conn(:post, "/posts")
    response = DefaultController.create(conn, ja_attrs(%{"title" => "valid"}))
    assert response.status == 201
  end

  test "default implimentation renders 422 if invalid" do
    conn = prep_conn(:post, "/posts")
    response = DefaultController.create(conn, ja_attrs(%{"title" => "invalid"}))
    assert response.status == 422
  end

  test "custom implimentation accepts cons" do
    conn = prep_conn(:post, "/posts")
    response = ProtectedController.create(conn, ja_attrs(%{"title" => "valid"}))
    assert response.status == 401
  end

  test "custom implimentation handles {:ok, model}" do
    conn = prep_conn(:post, "/posts")
    response = CustomController.create(conn, ja_attrs(%{"title" => "valid"}))
    assert response.status == 201
  end

  test "custom implimentation handles {:error, errors}" do
    conn = prep_conn(:post, "/posts")
    response = CustomController.create(conn, ja_attrs(%{"title" => "invalid"}))
    assert response.status == 422
  end

  def prep_conn(method, path, params \\ %{}) do
    params = Map.merge(params, %{"_format" => "json"})
    conn(method, path, params)
      |> fetch_query_params
      |> Phoenix.Controller.put_view(JaResourceTest.PostView)
  end

  defp ja_attrs(attrs) do
    %{
      "data" => %{
        "attributes" => attrs
      }
    }
  end
end
