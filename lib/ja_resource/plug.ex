defmodule JaResource.Plug do
  import Plug.Conn
  alias Phoenix.Controller
  @behaviour Plug

  @available [:index, :show, :create, :update, :delete]

  def init(opts) do
    Keyword.put(opts, :allowed, (opts[:only] || @available -- (opts[:except] || [])))
  end

  def call(conn, opts) do
    action = Controller.action_name(conn)
    if action in opts[:allowed] do
      conn
      |> dispatch_resource(action)
      |> halt
    else
      conn
    end
  end

  defp dispatch_resource(conn, :index),  do: JaResource.Index.call(conn)
  defp dispatch_resource(conn, :show),   do: JaResource.Show.call(conn)
  defp dispatch_resource(conn, :create), do: JaResource.Create.call(conn)
  defp dispatch_resource(conn, :update), do: JaResource.Update.call(conn)
  defp dispatch_resource(conn, :delete), do: JaResource.Delete.call(conn)
end
