defmodule JaResource.Show do
  use Behaviour
  import Plug.Conn

  @callback handle_show(Plug.Conn.t, JaResource.id) :: Plug.Conn.t | JaResource.record

  defmacro __using__(_) do
    quote do
      use JaResource.Record
      @behaviour JaResource.Show

      def show(conn, %{"id" => id}) do
        #todo, attribute normalization
        conn
        |> handle_show(id)
        |> JaResource.Show.respond(conn)
      end

      def handle_show(conn, id), do: record(conn, id)

      defoverridable [show: 2, handle_show: 2]
    end
  end

  @doc false
  def respond(%Plug.Conn{} = conn, _old_conn), do: conn
  def respond(nil, conn), do: send_resp(conn, :not_found, nil)
  def respond(model, conn), do: Phoenix.Controller.render(conn, :show, data: model)
end
