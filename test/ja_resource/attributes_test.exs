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

  test "formatting attributes from json-api params with relationships" do
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
          },
          "tag" => %{
            "data" => [
              %{"type" => "tag", "id" => "1"},
              %{"type" => "tag", "id" => "2"}
            ]
          }
        }
      }
    }
    merged = %{
      "type" => "post",
      "title" => "a post",
      "category_id" => "1",
      "tag_id" => ["1", "2"]
    }
    actual = JaResource.Attributes.from_params(params)
    assert actual == merged
  end

  test "formatting minimal attributes from json-api params" do
    params = %{
      "data" => %{
        "type" => "post",
        "attributes" => %{
          "title" => "a post"
        }
      }
    }
    merged = %{
      "type" => "post",
      "title" => "a post"
    }
    actual = JaResource.Attributes.from_params(params)
    assert actual == merged
  end
end
