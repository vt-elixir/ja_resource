defmodule JaResource.Update do
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
    * handle_invalid_update/2
    * render_update/2
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

  @doc """
  Returns a `Plug.Conn` in response to errors during update.

  Default implementation sets the status to `:unprocessable_entity` and renders
  the error messages provided.
  """
  @callback handle_invalid_update(Plug.Conn.t, Ecto.Changeset.t) :: Plug.Conn.t

  @doc """
  Returns a `Plug.Conn` in response to successful update.

  Default implementation renders the view.
  """
  @callback render_update(Plug.Conn.t, JaResource.record) :: Plug.Conn.t

  defmacro __using__(_) do
    quote do
      use JaResource.Record
      use JaResource.Attributes
      @behaviour JaResource.Update

      def handle_update(conn, nil, _params), do: nil
      def handle_update(_conn, model, attributes) do
        __MODULE__.model.changeset(model, attributes)
      end

      def handle_invalid_update(conn, errors) do
        conn
        |> put_status(:unprocessable_entity)
        |> Phoenix.Controller.render(:errors, data: errors)
      end

      def render_update(conn, model) do
        conn
        |> Phoenix.Controller.render(:show, data: model)
      end

      defoverridable [handle_update: 3, handle_invalid_update: 2, render_update: 2]
    end
  end

  @doc """
  Execute the update action on a given module implementing Update behaviour and conn.
  """
  def call(controller, conn) do
    model      = controller.record(conn, conn.params["id"])
    merged     = JaResource.Attributes.from_params(conn.params)
    attributes = controller.permitted_attributes(conn, merged, :update)

    conn
    |> controller.handle_update(model, attributes)
    |> JaResource.Update.update(controller)
    |> JaResource.Update.respond(conn, controller)
  end

  @doc false
  def update(%Ecto.Changeset{} = changeset, controller) do
    controller.repo().update(changeset)
  end
  if Code.ensure_loaded?(Ecto.Multi) do
    def update(%Ecto.Multi{} = multi, controller) do
      controller.repo().transaction(multi)
    end
  end
  def update(other, _controller), do: other

  @doc false
  def respond(%Plug.Conn{} = conn, _oldconn, _), do: conn
  def respond(nil, conn, _), do: send_resp(conn, :not_found, "")
  def respond({:error, errors}, conn, controller), do: controller.handle_invalid_update(conn, errors)
  def respond({:error, _name, errors, _changes}, conn, controller), do: controller.handle_invalid_update(conn, errors)
  def respond({:ok, model}, conn, controller), do: controller.render_update(conn, model)
  def respond(model, conn, controller), do: controller.render_update(conn, model)
end
