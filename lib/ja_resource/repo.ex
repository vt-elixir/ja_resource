defmodule JaResource.Repo do
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
      unless JaResource.Repo in @behaviour do
        @behaviour JaResource.Repo
        unquote(default_repo())
      end
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
