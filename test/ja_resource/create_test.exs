defmodule JaResource.CreateTest do
  use ExUnit.Case
  use Plug.Test
  alias JaResource.Create

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

  defmodule CustomResponseController do
    use Phoenix.Controller
    use JaResource.Create
    def repo, do: JaResourceTest.Repo
    def model, do: JaResourceTest.Post
    def handle_invalid_create(conn, errors),
      do: put_status(conn, 401) |> Phoenix.Controller.render(:errors, data: errors)
    def render_create(conn, model),
      do: put_status(conn, :ok) |> Phoenix.Controller.render(:show, data: model)
  end

  test "default implementation renders 201 if valid" do
    conn = prep_conn(:post, "/posts", ja_attrs(%{"title" => "valid"}))
    response = Create.call(DefaultController, conn)
    assert response.status == 201
  end

  test "default implementation renders 422 if invalid" do
    conn = prep_conn(:post, "/posts", ja_attrs(%{"title" => "invalid"}))
    response = Create.call(DefaultController, conn)
    assert response.status == 422
  end

  test "custom implementation accepts cons" do
    conn = prep_conn(:post, "/posts", ja_attrs(%{"title" => "valid"}))
    response = Create.call(ProtectedController, conn)
    assert response.status == 401
  end

  test "custom implementation handles {:ok, model}" do
    conn = prep_conn(:post, "/posts", ja_attrs(%{"title" => "valid"}))
    response = Create.call(CustomController, conn)
    assert response.status == 201
  end

  test "custom implementation handles {:error, errors}" do
    conn = prep_conn(:post, "/posts", ja_attrs(%{"title" => "invalid"}))
    response = Create.call(CustomController, conn)
    assert response.status == 422
  end

  test "custom implementation renders 200 if valid" do
    conn = prep_conn(:post, "/posts", ja_attrs(%{"title" => "valid"}))
    response = Create.call(CustomResponseController, conn)
    assert response.status == 200
  end

  test "custom implementation renders 401 if invalid" do
    conn = prep_conn(:post, "/posts", ja_attrs(%{"title" => "invalid"}))
    response = Create.call(CustomResponseController, conn)
    assert response.status == 401
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
