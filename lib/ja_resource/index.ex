defmodule JaResource.Index do
  use Behaviour
  import Plug.Conn, only: [put_status: 2]

  @moduledoc """
  Provides `handle_index/2`, `filter/4` and `sort/4` callbacks.

  It relies on (and uses):

    * JaResource.Repo
    * JaResource.Records
    * JaResource.Serializable

  When used JaResource.Index defines the `index/2` action suitable for handling
  json-api requests.

  To customize the behaviour of the index action the following callbacks can be implemented:

    * handle_index/2
    * filter/4
    * sort/4
    * JaResource.Records.records/1
    * JaResource.Repo.repo/0
    * JaResource.Serializable.serialization_opts/3

  """

  @doc """
  Returns the models to be represented by this resource.

  Default implementation is the result of the JaResource.Records.records/2
  callback. Usually a module or an `%Ecto.Query{}`.

  The results of this callback are passed to the filter and sort callbacks before the query is executed.

  `handle_index/2` can alternatively return a conn with any response/body.

  Example custom implementation:

      def handle_index(conn, _params) do
        case conn.assigns[:user] do
          nil  -> App.Post
          user -> User.own_posts(user)
        end
      end

  In most cases JaResource.Records.records/1, filter/4, and sort/4 are the
  better customization hooks.
  """
  @callback handle_index(Plug.Conn.t, map) :: Plug.Conn.t | JaResource.records

  @doc """
  Callback executed for each `filter` param.

  For example, if you wanted to optionally filter on an Article's category and
  issue, your request url might look like:

      /api/articles?filter[category]=elixir&filter[issue]=12

  You would then want two callbacks:

      def filter(_conn, query, "category", category) do
        where(query, category: category)
      end

      def filter(_conn, query, "issue", issue_id) do
        where(query, issue_id: issue_id)
      end

  You can also use guards to whitelist a handeful of attributes:

      @filterable_attrs ~w(title category author_id issue_id)
      def filter(_conn, query, attr, val) when attr in @filterable_attrs do
        where(query, [{String.to_existing_atom(attr), val}])
      end

  Anything not explicitly matched by your callbacks will be ignored.
  """
  @callback filter(Plug.Conn.t, JaResource.records, String.t, String.t) :: JaResource.records

  @doc """
  Callback executed for each value in the sort param.

  Fourth argument is the direction as an atom, either `:asc` or `:desc` based
  upon the presence or not of a `-` prefix.

  For example if you wanted to sort by date then title your request url might
  look like:

      /api/articles?sort=-created,title

  You would then want two callbacks:

      def sort(_conn, query, "created", direction) do
        order_by(query, [{direction, :inserted_at}])
      end

      def sort(_conn, query, "title", direction) do
        order_by(query, [{direction, :title}])
      end

  Anything not explicitly matched by your callbacks will be ignored.
  """
  @callback sort(Plug.Conn.t, JaResource.records, String.t, :asc | :dsc) :: JaResource.records

  @doc """
  Callback executed to query repo.

  By default this just calls `all/2` on the repo. Can be customized for
  pagination, monitoring, etc. For example to paginate with Scrivener:

      def handle_index_query(%{query_params: qp}, query) do
        repo().paginate(query, qp["page"] || %{})
      end

  """
  @callback handle_index_query(Plug.Conn.t, Ecto.Query.t | module) :: any

  @doc """
  Execute the index action on a given module implementing Index behaviour and conn.
  """
  def call(controller, conn) do
    conn
    |> controller.handle_index(conn.params)
    |> JaResource.Index.filter(conn, controller)
    |> JaResource.Index.sort(conn, controller)
    |> JaResource.Index.execute_query(conn, controller)
    |> JaResource.Index.respond(conn, controller)
  end

  defmacro __using__(_) do
    quote do
      use JaResource.Repo
      use JaResource.Records
      use JaResource.Serializable
      @behaviour JaResource.Index
      @before_compile JaResource.Index

      def handle_index_query(_conn, query), do: repo().all(query)
      defoverridable [handle_index_query: 2]

      def handle_index(conn, params), do: records(conn)
      defoverridable [handle_index: 2]
    end
  end

  @doc false
  defmacro __before_compile__(_) do
    quote do
      def filter(_conn, results,  _key, _val), do: results
      def sort(_conn, results,  _key, _dir), do: results
    end
  end

  @doc false
  def filter(results, conn = %{params: %{"filter" => filters}}, resource) do
    filters
    |> Dict.keys
    |> Enum.reduce(results, fn(k, acc) ->
      resource.filter(conn, acc, k, filters[k])
    end)
  end
  def filter(results, _conn, _controller), do: results

  @sort_regex ~r/(-?)(\S*)/
  @doc false
  def sort(results, conn = %{params: %{"sort" => fields}}, controller) do
    fields
    |> String.split(",")
    |> Enum.reduce(results, fn(field, acc) ->
      case Regex.run(@sort_regex, field) do
        [_, "", field]  -> controller.sort(conn, acc, field, :asc)
        [_, "-", field] -> controller.sort(conn, acc, field, :desc)
      end
    end)
  end
  def sort(results, _conn, _controller), do: results

  @doc false
  def execute_query(%Plug.Conn{} = conn, _conn, _controller), do: conn
  def execute_query(results, _conn, _controller) when is_list(results), do: results
  def execute_query(query, conn, controller), do: controller.handle_index_query(conn, query)

  @doc false
  def respond(%Plug.Conn{} = conn, _oldconn, _controller), do: conn
  def respond({:error, errors}, conn, _controller), do: error(conn, errors)
  def respond(models, conn, controller) do
    opts = controller.serialization_opts(conn, conn.query_params, models)
    Phoenix.Controller.render(conn, :index, data: models, opts: opts)
  end

  defp error(conn, errors) do
    conn
    |> put_status(:internal_server_error)
    |> Phoenix.Controller.render(:errors, data: errors)
  end
end
