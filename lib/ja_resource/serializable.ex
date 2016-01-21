defmodule JaResource.Serializable do
  @moduledoc """
  The `JaResource.Serializable` behavior is used to send serialization options
  such as `fields` and `include` to the serializer.

  It is `use`d by the `JaResource.Index` and `JaResource.Show` actions.

  `use` of this module defines a default implementation that passes `fields`
  and `include` params through un-touched. This may be overridden in your
  controller. For example:

      def serialization_opts(_conn, params) do
        %{
          fields: params["fields"] || %{"post" => "title,body"}
        }
      end

  """

  use Behaviour

  @doc """
  Converts full list of params into serialization opts.

  Typically this callback returns the list of fields and includes that were
  optionally requested by the stack.

  See http://github.com/AgilionApps/ja_serializer for option format.
  """
  @callback serialization_opts(Plug.Conn.t, map) :: map

  defmacro __using__(_) do
    quote do
      @behaviour JaResource.Serializable

      def serialization_opts(_conn, %{"fields" => f, "include" => i}),
        do: %{include: i, fields: f}
      def serialization_opts(_conn, %{"include" => i}),
        do: %{include: i}
      def serialization_opts(_conn, %{"fields" => f}),
        do: %{fields: f}
      def serialization_opts(_conn, _params),
        do: %{}

      defoverridable [serialization_opts: 2]
    end
  end
end
