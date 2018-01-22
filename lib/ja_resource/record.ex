defmodule JaResource.Record do
  @moduledoc """
  This behaviour is used by the following JaResource actions:

    * JaResource.Show
    * JaResource.Update
    * JaResource.Delete

  It relies on (and uses):

    * JaResource.Records

  """

  @doc """
  Used to get the subject of the current action

  Many/most controllers will override this:

      def record(%Plug.Conn{assigns: %{user_id: user_id}}, id) do
        model()
        |> where([p], p.author_id == ^user_id)
        |> Repo.get(id)
      end

  """
  @callback record(Plug.Conn.t, JaResource.id) :: Plug.Conn.t | JaResource.record

  defmacro __using__(_) do
    quote do
      unless JaResource.Record in @behaviour do
        use JaResource.Records
        @behaviour JaResource.Record

        def record(conn, id) do
          conn
          |> records
          |> repo().get(id)
        end

        defoverridable [record: 2]
      end
    end
  end
end
