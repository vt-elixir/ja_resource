defmodule JaResource.Index do
  use Behaviour

  @callback handle_index(Plug.Conn.t, map) :: Plug.Conn.t | JaResource.records

  @callback filter(String.t, JaResource.records, String.t) :: JaResource.records

  defmacro __using__(_) do
    quote do
      use JaResource.Records
      @behaviour JaResource.Index
      @before_compile JaResource.Index


      def index(conn, params) do
        conn
        |> handle_index(params)
        |> JaResource.Index.filter(conn, __MODULE__)
        |> JaResource.Index.sort(conn, __MODULE__)
        |> JaResource.Index.execute_query(__MODULE__)
        |> JaResource.Index.respond(conn)
      end

      def handle_index(conn, params), do: records(conn)

      defoverridable [index: 2, handle_index: 2]
    end
  end

  defmacro __before_compile__(_) do
    quote do
      def filter(_, results, _), do: results
      def sort(_, results, _), do: results
    end
  end

  @doc false
  def filter(results, conn, resource) do
    case conn.params["filter"] do
      nil -> results
      %{} = filters ->
        filters
        |> Dict.keys
        |> Enum.reduce(results, fn(k, acc) ->
          resource.filter(k, acc, filters[k])
        end)
    end
  end

  @sort_regex ~r/(-?)(\S*)/
  @doc false
  def sort(results, conn, resource) do
    case conn.params["sort"] do
      nil -> results
      fields ->
        fields
        |> String.split(",")
        |> Enum.reduce(results, fn(field, acc) ->
          case Regex.run(@sort_regex, field) do
            [_, "", field] -> resource.sort(field, acc, :asc)
            [_, "-", field] -> resource.sort(field, acc, :desc)
          end
        end)
    end
  end

  @doc false
  def execute_query(%Ecto.Query{} = q, controller), do: controller.repo.all(q)
  def execute_query(%Plug.Conn{} = conn, _controller), do: conn
  def execute_query(m, controller) when is_atom(m), do: controller.repo.all(m)
  def execute_query(results, _controller) when is_list(results), do: results

  @doc false
  def respond(%Plug.Conn{} = conn, _oldconn), do: conn
  def respond(models, conn) do
    Phoenix.Controller.render(conn, :index, data: models)
  end
end
