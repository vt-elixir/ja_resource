defmodule JaResource.Records do
  @moduledoc """
  Provides the `records/1` callback used for querying records to be served.

  This is typically the base query that you expose, often scoped to the
  current user.

  This behaviour is used by the following JaResource actions:

    * JaResource.Index
    * JaResource.Show
    * JaResource.Update
    * JaResource.Delete

  It relies on (and uses):

    * JaResource.Model

  """

  @doc """
  Used to get the base query of records.

  Many/most controllers will override this:

      def records(%Plug.Conn{assigns: %{user_id: user_id}}) do
        model()
        |> where([p], p.author_id == ^user_id)
      end

  Return value should be %Plug.Conn{} or an %Ecto.Query{}.
  """
  @callback records(Plug.Conn.t) :: Plug.Conn.t | JaResource.records

  defmacro __using__(_) do
    quote do
      use JaResource.Model
      @behaviour JaResource.Records

      def records(_conn), do: model()

      defoverridable [records: 1]
    end
  end
end
