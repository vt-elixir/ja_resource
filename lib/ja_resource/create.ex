defmodule JaResource.Create do
  @moduledoc """
  Defines a behaviour for creating a resource and the function to execute it.

  It relies on (and uses):

    * JaResource.Repo
    * JaResource.Model
    * JaResource.Attributes

  When used JaResource.Create defines the following overrideable callbacks:

    * handle_create/2
    * handle_invalid_create/2
    * render_create/2
    * JaResource.Attributes.permitted_attributes/3
    * JaResource.Repo.repo/1

  """

  @doc """
  Returns an unpersisted changeset or persisted model of the newly created object.

  Default implementation returns the results of calling
  `Model.changeset(%Model{}, attrs)` where Model is the model defined by the
  `JaResource.Model.model/0` callback.

  The attributes argument is the result of the `permitted_attributes` function.

  `handle_create/2` can return an %Ecto.Changeset, an Ecto.Schema struct,
  a list of errors (`{:error, [email: "is not valid"]}` or a conn with
  any response/body.

  Example custom implementation:

      def handle_create(_conn, attributes) do
        Post.changeset(%Post{}, attributes, :create_and_publish)
      end

  """
  @callback handle_create(Plug.Conn.t, JaResource.attributes) :: Plug.Conn.t | Ecto.Changeset.t | JaResource.record | {:ok, JaResource.record} | {:error, JaResource.validation_errors}

  @doc """
  Returns a `Plug.Conn` in response to errors during create.

  Default implementation sets the status to `:unprocessable_entity` and renders
  the error messages provided.
  """
  @callback handle_invalid_create(Plug.Conn.t, Ecto.Changeset.t) :: Plug.Conn.t

  @doc """
  Returns a `Plug.Conn` in response to successful create.

  Default implementation sets the status to `:created` and renders the view.
  """
  @callback render_create(Plug.Conn.t, JaResource.record) :: Plug.Conn.t

  defmacro __using__(_) do
    quote do
      @behaviour JaResource.Create
      use JaResource.Repo
      use JaResource.Attributes
      import Plug.Conn

      def handle_create(_conn, attributes) do
        __MODULE__.model.changeset(__MODULE__.model.__struct__, attributes)
      end

      def handle_invalid_create(conn, errors) do
        conn
        |> put_status(:unprocessable_entity)
        |> Phoenix.Controller.render(:errors, data: errors)
      end

      def render_create(conn, model) do
        conn
        |> put_status(:created)
        |> Phoenix.Controller.render(:show, data: model)
      end

      defoverridable [handle_create: 2, handle_invalid_create: 2, render_create: 2]
    end
  end

  @doc """
  Creates a resource given a module using Create and a connection.

      Create.call(ArticleController, conn)

  Dispatched by JaResource.Plug when phoenix action is create.
  """
  def call(controller, conn) do
    merged = JaResource.Attributes.from_params(conn.params)
    attributes = controller.permitted_attributes(conn, merged, :create)
    conn
    |> controller.handle_create(attributes)
    |> JaResource.Create.insert(controller)
    |> JaResource.Create.respond(conn, controller)
  end

  @doc false
  def insert(%Ecto.Changeset{} = changeset, controller) do
    controller.repo().insert(changeset)
  end
  if Code.ensure_loaded?(Ecto.Multi) do
    def insert(%Ecto.Multi{} = multi, controller) do
      controller.repo().transaction(multi)
    end
  end
  def insert(other, _controller), do: other

  @doc false
  def respond(%Plug.Conn{} = conn, _old_conn, _), do: conn
  def respond({:error, errors}, conn, controller), do: controller.handle_invalid_create(conn, errors)
  def respond({:error, _name, errors, _changes}, conn, controller), do: controller.handle_invalid_create(conn, errors)
  def respond({:ok, model}, conn, controller), do: controller.render_create(conn, model)
  def respond(model, conn, controller), do: controller.render_create(conn, model)
end
