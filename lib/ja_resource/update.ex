defmodule JaResource.Update do
  use Behaviour
  import Plug.Conn

  @callback handle_update(Plug.Conn.t, JaResource.record, JaResource.attributes) :: Plug.Conn.t | JaResource.record | nil

  defmacro __using__(_) do
    quote do
      use JaResource.Record
      use JaResource.Attributes
      @behaviour JaResource.Update

      def update(conn, %{"id" => id} = params) do
        model      = record(conn, id)
        merged     = JaResource.attrs_from_params(params)
        attributes = permitted_attributes(conn, merged, :update)

        conn
        |> handle_update(model, attributes)
        |> JaResource.Update.update(__MODULE__)
        |> JaResource.Update.respond(conn)
      end

      def handle_update(conn, nil, _params), do: nil

      defoverridable [update: 2, handle_update: 3]
    end
  end

  @doc false
  def update(%Ecto.Changeset{} = changeset, controller) do 
    controller.repo.update(changeset)
  end
  if Code.ensure_loaded?(Ecto.Multi) do
    def update(%Ecto.Multi{} = multi, controller) do
      controller.repo.transaction(multi)
    end
  end
  def update(other, _controller), do: other

  def respond(%Plug.Conn{} = conn, _oldconn), do: conn
  def respond(nil, conn), do: send_resp(conn, :not_found, nil)
  def respond({:error, errors}, conn), do: invalid(conn, errors)
  def respond({:ok, model}, conn), do: updated(conn, model)
  def respond(model, conn), do: updated(conn, model)

  defp updated(conn, model) do
    conn
    |> Phoenix.Controller.render(:show, data: model)
  end

  defp invalid(conn, errors) do
    conn
    |> put_status(:unprocessable_entity)
    |> Phoenix.Controller.render(:errors, data: errors)
  end
end
