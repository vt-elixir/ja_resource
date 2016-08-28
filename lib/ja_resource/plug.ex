defmodule JaResource.Plug do
  import Plug.Conn
  alias Phoenix.Controller
  alias JaResource.{Index,Show,Create,Update,Delete}
  @behaviour Plug

  @moduledoc """
  Implements a plug that dispatches Phoenix actions to JaResource action behaviours.

  You can optionally whitelist or blacklist the actions JaResource will respond
  to. Any actions outside of the standard index, show, create, update, and
  delete are always ignored and dispatched by Phoenix as usual. Any
  non-whitelisted or blacklisted actions are likewize passed to Phoenix as usual.

  For example:

      defmodule MyApp.V1.ArticleController do
        use MyApp.Web, :controller
        use JaResource
        plug JaResource, except: [:delete]
        # same as:
        # plug JaResource, only: [:index, :show, :create, :update]

        # Standard Phoenix Delete
        def delete(conn, params) do
          # Custom delete logic
        end

        # Non restful action
        def publish(conn, params) do
          # Custom publish logic
        end
      end

  When dispatching an action you must have implemented the action behaviours
  callbacks. This is typically done with `use JaResource` and customized.
  Alternatively you can use the individual actions, such as
  `use JaResource.Create`. You can even include just the behaviour and define
  all the callbacks yourself via `@behaviour JaResource.Create`.

  See the action behaviours to learn how to customize each action.
  """

  @available [:index, :show, :create, :update, :delete]

  def init(opts) do
    allowed = cond do
      opts[:only]   -> opts[:only] -- (opts[:only] -- @available)
      opts[:except] -> @available -- opts[:except]
      true          -> @available
    end

    [allowed: allowed]
  end

  def call(conn, opts) do
    action     = Controller.action_name(conn)
    controller = Controller.controller_module(conn)
    if action in opts[:allowed] do
      conn
      |> dispatch(controller, action)
      |> halt
    else
      conn
    end
  end

  defp dispatch(conn, controller, :index),  do: Index.call(controller, conn)
  defp dispatch(conn, controller, :show),   do: Show.call(controller, conn)
  defp dispatch(conn, controller, :create), do: Create.call(controller, conn)
  defp dispatch(conn, controller, :update), do: Update.call(controller, conn)
  defp dispatch(conn, controller, :delete), do: Delete.call(controller, conn)
end
