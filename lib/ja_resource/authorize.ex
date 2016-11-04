defmodule JaResource.Authorize do
  use Behaviour

  @moduledoc """
  Provides the `handle_authorize/0` callback used to authorize the resource.

  This behaviour is used by all JaResource actions.
  """

  @doc """
  Called before all the actions with the model. Useful for authorizing.
  """
  @callback handle_authorize(Plug.Conn.t, JaResource.record) :: any

  defmacro __using__(_) do
    quote do
      @behaviour JaResource.Authorize

      def handle_authorize(model, _conn), do: model

      defoverridable [handle_authorize: 2]
    end
  end
end
