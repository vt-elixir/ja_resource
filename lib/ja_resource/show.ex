defmodule JaResource.Show do
  use Behaviour
  import Plug.Conn

  @callback handle_show(Plug.Conn.t, JaResource.id) :: Plug.Conn.t | JaResource.record

  defmacro __using__(_) do
    quote do
      use JaResource.Record
      use JaResource.Serializable
      @behaviour JaResource.Show

      def show(conn, %{"id" => id}) do
        conn
        |> handle_show(id)
        |> JaResource.Show.respond(conn, __MODULE__)
      end

      def handle_show(conn, id), do: record(conn, id)

      defoverridable [show: 2, handle_show: 2]
    end
  end

  @doc false
  def respond(%Plug.Conn{} = conn, _old_conn, _controller), do: conn
  def respond(nil, conn, _controller), do: send_resp(conn, :not_found, nil)
  def respond(model, conn, controller) do
    opts = controller.serialization_opts(conn, conn.query_params)
    Phoenix.Controller.render(conn, :show, data: model, opts: opts)
  end
end
