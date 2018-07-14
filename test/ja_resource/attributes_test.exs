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
        "id" => "1",
        "type" => "post",
        "attributes" => %{
          "title" => "a post"
        },
        "relationships" => %{
          "category" => %{
            "data" => %{
              "type" => "category",
              "id" => "1"
            }
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
      "tag_ids" => ["1", "2"]
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

  test "formatting only relationships from json-api params" do
    params = %{
      "data" => %{
        "type" => "post",
        "relationships" => %{
          "category" => %{
            "data" => %{
              "type" => "category",
              "id" => "1"
            }
          }
        }
      }
    }
    merged = %{
      "type" => "post",
      "category_id" => "1"
    }
    actual = JaResource.Attributes.from_params(params)
    assert actual == merged
  end

  test "formatting only relationships from json-api params, with embedded attributes" do
    params = %{
      "data" => %{
        "type" => "post",
        "relationships" => %{
          "categories" => %{
            "data" => [
              %{
                "attributes" => %{
                  "name" => "Category Name"
                },
                "type" => "category",
                "id" => "1"
              },
              %{
                "attributes" => %{
                  "name" => "Other Category Name"
                },
                "type" => "category",
                "id" => "2"
              }
            ]
          }
        }
      }
    }
    merged = %{
      "type" => "post",
      "categories" => [
        %{
          "name" => "Category Name",
          "id" => "1"
        },
        %{
          "name" => "Other Category Name",
          "id" => "2"
        }
      ]
    }
    actual = JaResource.Attributes.from_params(params)
    assert actual == merged
  end

  test "formatting nested relationships from json-api params, with embedded attributes" do
    params = %{
      "data" => %{
        "attributes" => %{
          "name" => "Test"
        },
        "id" => "6af961ee-ec6d-47af-8448-74c281dd6c6b",
        "relationships" => %{
          "first_item" => %{
            "data" => %{
              "id" => "a1d67f8e-74a3-41ac-956d-619caa0421f9",
              "type" => "items"
            }
          },
          "paths" => %{
            "data" => [
              %{
                "attributes" => %{
                  "formula" => nil,
                  "input" => 3
                },
                "id" => "7ca35dbd-8054-4e17-a914-ac125216fdd2",
                "relationships" => %{
                  "from_item" => %{
                    "data" => %{
                      "id" => "a1d67f8e-74a3-41ac-956d-619caa0421f9",
                      "type" => "items"
                    }
                  },
                  "to_item" => %{
                    "data" => %{
                      "id" => "8b02344b-5399-4e95-a51e-8a7186a59459",
                      "type" => "items"
                    }
                  }
                },
                "type" => "flow-paths"
              }
            ]
          }
        },
        "type" => "flows"
      },
      "id" => "6af961ee-ec6d-47af-8448-74c281dd6c6b"
    }
    merged = %{
      "type" => "flows",
      "first_item_id" => "a1d67f8e-74a3-41ac-956d-619caa0421f9",
      "name" => "Test",
      "paths" => [
        %{
          "formula" => nil,
          "from_item_id" => "a1d67f8e-74a3-41ac-956d-619caa0421f9",
          "id" => "7ca35dbd-8054-4e17-a914-ac125216fdd2",
          "input" => 3,
          "to_item_id" => "8b02344b-5399-4e95-a51e-8a7186a59459"
        }
      ]
    }
    actual = JaResource.Attributes.from_params(params)
    assert actual == merged
  end
end
