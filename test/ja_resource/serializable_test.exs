defmodule JaResource.SerializableTest do
  use ExUnit.Case

  defmodule Default do
    use JaResource.Serializable
  end

  defmodule Override do
    use JaResource.Serializable

    def serialization_opts(_conn, params) do
      %{fields: %{"article" => params["fields"]["post"]}}
    end
  end

  test "default behaviour - no opts" do
    conn = %Plug.Conn{}
    given = %{}
    expected = %{}
    assert Default.serialization_opts(conn, given) == expected
  end

  test "default behaviour - both opts" do
    conn = %Plug.Conn{}
    given = %{"fields" => %{"post" => "title,body"}, "include" => "author"}
    expected = %{fields: %{"post" => "title,body"}, include: "author"}
    assert Default.serialization_opts(conn, given) == expected
  end

  test "default behaviour - field only" do
    conn = %Plug.Conn{}
    given = %{"fields" => %{"post" => "title,body"}}
    expected = %{fields: %{"post" => "title,body"}}
    assert Default.serialization_opts(conn, given) == expected
  end

  test "default behaviour - include only" do
    conn = %Plug.Conn{}
    given = %{"include" => "author"}
    expected = %{include: "author"}
    assert Default.serialization_opts(conn, given) == expected
  end

  test "overridden behaviour" do
    conn = %Plug.Conn{}
    given = %{"fields" => %{"post" => "title,body"}}
    expected = %{fields: %{"article" => "title,body"}}
    assert Override.serialization_opts(conn, given) == expected
  end

end
