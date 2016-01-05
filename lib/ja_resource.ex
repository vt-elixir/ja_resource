defmodule JaResource do

  @type record :: map() | Ecto.Schema.t
  @type records :: module | Ecto.Query.t | list(record)
  @type params :: map()
  @type attributes :: map()
  @type id :: String.t

  defmacro __using__(opts) do
    quote do
      unquote(JaResource.use_action_behaviours(opts))
    end
  end

  @doc false
  def use_action_behaviours(opts) do
    available = [:index, :show, :create, :update, :delete]
    allowed = (opts[:only] || available -- (opts[:except] || []))

    quote bind_quoted: [allowed: allowed] do
      if :index  in allowed, do: use JaResource.Index
      if :show   in allowed, do: use JaResource.Show
      if :create in allowed, do: use JaResource.Create
      if :update in allowed, do: use JaResource.Update
      if :delete in allowed, do: use JaResource.Delete
    end
  end

  @doc false
  def attrs_from_params(%{"data" => %{"attributes" => attrs}} = params) do
    params["data"]
    |> parse_relationships
    |> Map.merge(attrs)
    |> Map.put_new("type", params["type"])
  end

  defp parse_relationships(%{"relationships" => nil}) do
    %{}
  end
  defp parse_relationships(%{"relationships" => relationships}) do
    Enum.reduce relationships, %{}, fn({name, %{"id" => id}}, rel) ->
      Map.put(rel, "#{name}_id", id)
    end
  end
end

defmodule JaResource.Records do
  use Behaviour

  @callback records(Plug.Conn.t) :: Plug.Conn.t | JaResource.records

  defmacro __using__(_) do
    quote do
      @behaviour JaResource.Records
    end
  end
end

defmodule JaResource.Record do
  use Behaviour

  @callback record(Plug.Conn.t, JaResource.id) :: Plug.Conn.t | JaResource.record

  defmacro __using__(_) do
    quote do
      use JaResource.Records
      @behaviour JaResource.Record

      def record(conn, id) do
        conn
        |> records
        |> repo.get(id)
      end

      defoverridable [record: 2]
    end
  end
end
