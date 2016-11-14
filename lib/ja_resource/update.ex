defmodule JaResource.Update do
  use Behaviour
  import Plug.Conn

  @moduledoc """
  Defines a behaviour for updating a resource and the function to execute it.

  It relies on (and uses):

    * JaResource.Record
    * JaResource.Attributes

  When used JaResource.Update defines the `update/2` action suitable for
  handling json-api requests.

  To customize the behaviour of the update action the following callbacks can
  be implemented:

    * JaResource.Record.record/2
    * JaResource.Records.records/1
    * handle_update/3
    * JaResource.Attributes.permitted_attributes/3

  """

  @doc """
  Returns an unpersisted changeset or persisted model representing the newly updated model.

  Receives the conn, the model as found by `record/2`, and the attributes
  argument from the `permitted_attributes` function.

  Default implementation returns the results of calling
  `Model.changeset(model, attrs)`.

  `handle_update/3` can return an %Ecto.Changeset, an Ecto.Schema struct,
  a list of errors (`{:error, [email: "is not valid"]}` or a conn with
  any response/body.

  Example custom implementation:

      def handle_update(conn, post, attributes) do
        current_user_id = conn.assigns[:current_user].id
        case post.author_id do
          ^current_user_id -> {:error, author_id: "you can only edit your own posts"}
          _                -> Post.changeset(post, attributes, :update)
        end
      end

  """
  @callback handle_update(Plug.Conn.t, JaResource.record, JaResource.attributes) :: Plug.Conn.t | JaResource.record | nil

  defmacro __using__(_) do
    quote do
      use JaResource.Record
      use JaResource.Attributes
      @behaviour JaResource.Update

      def handle_update(conn, nil, _params), do: nil
      def handle_update(_conn, model, attributes) do
        __MODULE__.model.changeset(model, attributes)
      end

      defoverridable [handle_update: 3]
    end
  end

  @doc """
  Execute the update action on a given module implementing Update behaviour and conn.
  """
  def call(controller, conn) do
    model      = controller.record(conn, conn.params["id"])
    merged     = JaResource.Attributes.from_params(conn.params)
    attributes = controller.permitted_attributes(conn, merged, :update)

    controller.handle_authorize(model, conn)

    conn
    |> controller.handle_update(model, attributes)
    |> JaResource.Update.update(controller)
    |> JaResource.Update.respond(conn)
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

  @doc false
  def respond(%Plug.Conn{} = conn, _oldconn), do: conn
  def respond(nil, conn), do: send_resp(conn, :not_found, "")
  def respond({:error, _name, errors, _changes}, conn), do: invalid(conn, errors)
  def respond({:error, errors}, conn), do: invalid(conn, errors)
  def respond({:ok, %{} = map}, conn), do: created(conn, Map.fetch(map, controller.atom()))
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
