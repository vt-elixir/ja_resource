defmodule JaResource.AttributesTest do
  use ExUnit.Case

  defmodule DefaultController do
    use JaResource.Attributes
  end

  defmodule CustomController do
    use JaResource.Attributes

    def permitted_attributes(_conn, attrs, _) do
      Map.take(attrs, ~w(title))
    end
  end

  test "permitted attributes default" do
    attrs = %{
      "type" => "post",
      "title" => "a post",
      "category_id" => "1"
    }
    actual = DefaultController.permitted_attributes(%Plug.Conn{}, attrs, :update)
    assert actual == attrs
  end

  test "permitted attributes custom" do
    attrs = %{
      "type" => "post",
      "title" => "a post",
      "category_id" => "1"
    }
    actual = CustomController.permitted_attributes(%Plug.Conn{}, attrs, :update)
    assert actual == %{"title" => "a post"}
  end

  test "formatting attributes from json-api params" do
    params = %{
      "data" => %{
        "id"   => "1",
        "type" => "post",
        "attributes" => %{
          "title" => "a post"
        },
        "relationships" => %{
          "category" => %{
            "data" => %{"type" => "category", "id" => "1"}
          }
        }
      }
    }
    merged = %{
      "type" => "post",
      "title" => "a post",
      "category_id" => "1"
    }
    actual = JaResource.Attributes.from_params(params)
    assert actual == merged
  end
end
