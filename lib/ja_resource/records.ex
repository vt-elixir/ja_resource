defmodule JaResource.Records do
  use Behaviour

  @moduledoc """
  This behaviour is used by the following JaResource actions:
    
    * JaResource.Index
    * JaResource.Show
    * JaResource.Update
    * JaResource.Delete

  It relies on:

    * JaResource.Model

  """

  @doc """
  Used to get the base query of records. 
  
  Many/most controllers will override this:

      def records(%Plug.Conn{assigns: %{user_id: user_id}}) do
        model()
        |> where([p], p.author_id == ^user_id)
      end

  """
  @callback records(Plug.Conn.t) :: Plug.Conn.t | JaResource.records

  defmacro __using__(_) do
    quote do
      @behaviour JaResource.Records
      
      def records(_conn), do: model()

      defoverridable [records: 1]
    end
  end
end
