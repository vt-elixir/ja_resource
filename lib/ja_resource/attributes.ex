defmodule JaResource.Attributes do
  @moduledoc """
  Provides the `permitted_attributes/3` callback used for filtering attributes.

  This behaviour is used by the following JaResource actions:

    * JaResource.Delete
    * JaResource.Create
  """

  @doc """
  Used to determine which attributes are permitted during create and update.

  The attributes map (the second argument) is a "flattened" version including
  the values at `data/attributes`, `data/type` and any relationship values in
  `data/relationships/[name]/data/id` as `name_id`.

  The third argument is the atom of the action being called.

  Example:

      defmodule MyApp.V1.PostController do
        use MyApp.Web, :controller
        use JaResource

        def permitted_attributes(conn, attrs, :create) do
          attrs
          |> Map.take(~w(title body type category_id))
          |> Map.merge("author_id", conn.assigns[:current_user])
        end

        def permitted_attributes(_conn, attrs, :update) do
          Map.take(attrs, ~w(title body type category_id))
        end
      end

  """
  @callback permitted_attributes(Plug.Conn.t, JaResource.attributes, :update | :create) :: JaResource.attributes

  defmacro __using__(_) do
    quote do
      unless JaResource.Attributes in @behaviour do
        @behaviour JaResource.Attributes

        def permitted_attributes(_conn, attrs, _), do: attrs

        defoverridable [permitted_attributes: 3]
      end
    end
  end

  @doc false
  def from_params(%{"data" => data}) do
    attrs = data["attributes"] || %{}

    data
    |> parse_relationships
    |> Map.merge(attrs)
    |> Map.put_new("type", data["type"])
  end

  defp parse_relationships(%{"relationships" => nil}) do
    %{}
  end

  defp parse_relationships(%{"relationships" => rels}) do
    Enum.reduce rels, %{}, fn
      ({name, %{"data" => nil}}, rel) ->
        Map.put(rel, "#{name}_id", nil)
      ({name, %{"data" => %{"id" => id}}}, rel) ->
        Map.put(rel, "#{name}_id", id)
      ({name, %{"data" => ids}}, rel) when is_list(ids) ->
        Map.put(rel, "#{name}_ids", Enum.map(ids, &(&1["id"])))
    end
  end

  defp parse_relationships(_) do
    %{}
  end
end
