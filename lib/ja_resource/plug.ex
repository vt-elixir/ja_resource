defmodule JaResource.Plug do
  import Plug.Conn
  alias Phoenix.Controller
  alias JaResource.{Index,Show,Create,Update,Delete}
  @behaviour Plug

  @available [:index, :show, :create, :update, :delete]

  def init(opts) do
    Keyword.put(opts, :allowed, (opts[:only] || @available -- (opts[:except] || [])))
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
