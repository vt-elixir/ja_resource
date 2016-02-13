defmodule JaResource.Delete do
  use Behaviour
  import Plug.Conn

  @callback handle_delete(Plug.Conn.t, JaResource.record) :: Plug.Conn.t | JaResource.record | nil

  defmacro __using__(_) do
    quote do
      use JaResource.Record
      @behaviour JaResource.Delete

      def delete(conn, %{"id" => id}) do
        model = record(conn, id)

        conn
        |> handle_delete(model)
        |> JaResource.Delete.respond(conn)
      end

      def handle_delete(conn, nil), do: nil
      def handle_delete(conn, model), do: __MODULE__.repo.delete(model)

      defoverridable [handle_delete: 2]
    end
  end

  def respond(nil, conn), do: not_found(conn)
  def respond(%Plug.Conn{} = conn, _old_conn), do: conn
  def respond({:ok, _model}, conn), do: deleted(conn)
  def respond({:errors, errors}, conn), do: invalid(conn, errors)
  def respond(_model, conn), do: deleted(conn)

  defp not_found(conn) do
    conn
    |> send_resp(:not_found, "")
  end

  defp deleted(conn) do
    conn
    |> send_resp(:no_content, "")
  end

  defp invalid(conn, errors) do
    conn
    |> put_status(:unprocessable_entity)
    |> Phoenix.Controller.render(:errors, data: errors)
  end
end
