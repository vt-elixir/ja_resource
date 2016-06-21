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

  defmacro __using__(_opts) do
    quote do
      @behaviour JaResource
      unquote(JaResource.default_repo)

      # TODO: Extract JaResource.Repo to own module
      #use JaResourse.Repo
      use JaResource.Index
      use JaResource.Show
      use JaResource.Create
      use JaResource.Update
      use JaResource.Delete

      plug JaResource.Plug
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
end
