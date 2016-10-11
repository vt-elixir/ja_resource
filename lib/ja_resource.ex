defmodule JaResource do
  @type record :: map() | Ecto.Schema.t
  @type records :: module | Ecto.Query.t | list(record)
  @type params :: map()
  @type attributes :: map()
  @type id :: String.t

  @moduledoc """
  When used, includes all restful actions behaviours. Also a plug.

  Example usage in phoenix controller:

      defmodule Example.ArticleController do
        use Example.Web, :controller
        use JaResource
        plug JaResource, except: [:create]
      end

  See JaResource.Plug for plug options and documentation.

  See the "action" behaviours for info on customizing each behaviour:

    * JaResource.Index
    * JaResource.Show
    * JaResource.Create
    * JaResource.Update
    * JaResource.Delete

  """

  defmacro __using__(_opts) do
    quote do
      use JaResource.Index
      use JaResource.Show
      use JaResource.Create
      use JaResource.Update
      use JaResource.Delete
    end
  end

  @behaviour Plug
  defdelegate init(opts),       to: JaResource.Plug
  defdelegate call(conn, opts), to: JaResource.Plug
end
