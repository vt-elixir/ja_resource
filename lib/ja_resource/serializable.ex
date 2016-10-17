defmodule JaResource.Serializable do
  @moduledoc """
  The `JaResource.Serializable` behavior is used to send serialization options
  such as `fields` and `include` to the serializer.

  It is `use`d by the `JaResource.Index` and `JaResource.Show` actions.

  `use` of this module defines a default implementation that passes `fields`
  and `include` params through un-touched. This may be overridden in your
  controller. For example:

      def serialization_opts(_conn, params, _models) do
        %{
          fields: params["fields"] || %{"post" => "title,body"}
        }
      end

  As another example, the callback could be used to add a meta map to the JSON
  payload, such as for pagination info, when using scrivener.

      def serialization_opts(_conn, _params, models) do
        %{
          meta: %{
            current_page: models.page_number,
            page_size: models.page_size,
            total_pages: models.total_pages,
            total_records: models.total_entries
          }
        }
      end

  Note that `models` will be a Scrivener page struct, if `handle_index_query` was
  overriden for Scrivener pagination.

  """

  use Behaviour

  @doc """
  Converts full list of params into serialization opts.

  Typically this callback returns the list of fields and includes that were
  optionally requested by the stack.

  It can also be used to add a meta to the payload,
  such as for scrivener pagination, on an index endpoint.

  See http://github.com/AgilionApps/ja_serializer for option format.
  """
  @callback serialization_opts(Plug.Conn.t, map, struct | list) :: Keyword.t

  defmacro __using__(_) do
    quote do
      @behaviour JaResource.Serializable

      def serialization_opts(_conn, %{"fields" => f, "include" => i}, _model_or_models),
        do: [include: i, fields: f]
      def serialization_opts(_conn, %{"include" => i}, _model_or_models),
        do: [include: i]
      def serialization_opts(_conn, %{"fields" => f}, _model_or_models),
        do: [fields: f]
      def serialization_opts(_conn, _params, _model_or_models),
        do: []

      defoverridable [serialization_opts: 3]
    end
  end
end
