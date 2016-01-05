defmodule JaResource.Create do
  use Behaviour
  import Plug.Conn

  @callback handle_create(Plug.Conn.t, JaResource.attributes) :: Plug.Conn.t | JaResource.record

  defmacro __using__(_) do
    quote do
      @behaviour JaResource.Create
      use JaResource.Attributes

      def create(conn, params) do
        merged = JaResource.attrs_from_params(params)
        attributes = permitted_attributes(conn, merged, :create)
        conn
        |> handle_create(attributes)
        |> JaResource.Create.insert(__MODULE__)
        |> JaResource.Create.respond(conn)
      end

      def handle_create(conn, params), do: records(conn)

      defoverridable [create: 2, handle_create: 2]
    end
  end

  @doc false
  def insert(%Ecto.Changeset{} = changeset, controller) do 
    controller.repo.insert(changeset)
  end
  if Code.ensure_loaded?(Ecto.Multi) do
    def insert(%Ecto.Multi{} = multi, controller) do
      controller.repo.transaction(multi)
    end
  end
  def insert(other, _controller), do: other

  @doc false
  def respond(%Plug.Conn{} = conn, _old_conn), do: conn
  def respond({:error, errors}, conn), do: invalid(conn, errors)
  def respond({:ok, model}, conn), do: created(conn, model)
  def respond(model, conn), do: created(conn, model)

  defp created(conn, model) do
    conn
    |> put_status(:created)
    |> Phoenix.Controller.render(:show, data: model)
  end

  defp invalid(conn, errors) do
    conn
    |> put_status(:unprocessable_entity)
    |> Phoenix.Controller.render(:errors, data: errors)
  end
end
