defmodule JaResource do
  @type record :: map() | Ecto.Schema.t
  @type records :: module | Ecto.Query.t | list(record)
  @type params :: map()
  @type attributes :: map()
  @type id :: String.t

  defmacro __using__(_opts) do
    quote do
      use JaResource.Repo
      use JaResource.Index
      use JaResource.Show
      use JaResource.Create
      use JaResource.Update
      use JaResource.Delete
    end
  end
end
