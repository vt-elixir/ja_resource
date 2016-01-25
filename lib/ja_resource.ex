defmodule JaResource do
  use Behaviour

  @type record :: map() | Ecto.Schema.t
  @type records :: module | Ecto.Query.t | list(record)
  @type params :: map()
  @type attributes :: map()
  @type id :: String.t

  @doc """
  Defines the module `use`-ing `Ecto.Repo` to be used by the controller.

  Defaults to the value set in config if present:

      config :ja_resource,
         repo: MyApp.Repo

  Default can be overridden per controller:

      def repo, do: MyApp.SecondaryRepo

  """
  @callback repo() :: module

  defmacro __using__(opts) do
    quote do
      use JaResource.Model
      @behaviour JaResource
      unquote(JaResource.use_action_behaviours(opts))
      unquote(JaResource.default_repo)
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
  def default_repo do
    quote do
      if Application.get_env(:ja_resource, :repo) do
        def repo, do: Application.get_env(:ja_resource, :repo)
        defoverridable [repo: 0]
      end
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
