defmodule JaResource.Attributes do
  use Behaviour
  import Plug.Conn

  @callback permitted_attributes(Plug.Conn.t, JaResource.attributes, :update | :create) :: JaResourse.attributes

  defmacro __using__(_) do
    quote do
      @behaviour JaResource.Attributes

      def permitted_attributes(_conn, attrs, _), do: attrs

      defoverridable [permitted_attributes: 3]
    end
  end
end
