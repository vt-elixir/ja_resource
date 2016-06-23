defmodule JaResource.PlugTest do
  use ExUnit.Case
  use Plug.Test

  defmodule Example do
    def handle_index(conn, _),  do: assign(conn, :handler, :index)
  end

  test "init returns all actions by default" do
    assert [{:allowed, allowed}] = JaResource.Plug.init([])
    assert allowed == [:index, :show, :create, :update, :delete]
  end

  test "init returns only valid whitelisted actions" do
    assert [{:allowed, allowed}] = JaResource.Plug.init(only: [:index, :foo])
    assert allowed == [:index]
  end

  test "init returns available minus blacklisted actions" do
    assert [{:allowed, allowed}] = JaResource.Plug.init(except: [:index, :foo])
    assert allowed == [:show, :create, :update, :delete]
  end

  test "it dispatches known, allowed actions to the behaviour" do
    conn = %Plug.Conn{
      private: %{
        phoenix_controller: JaResource.PlugTest.Example,
        phoenix_action:     :index
      },
      params: %{}
    }
    results = JaResource.Plug.call(conn, allowed: [:index])
    assert results.assigns[:handler] == :index
  end

  test "it does not dispatch known, unallowed actions to the behaviour" do
    conn = %Plug.Conn{
      private: %{
        phoenix_controller: JaResource.PlugTest.Example,
        phoenix_action:     :index
      },
      params: %{}
    }
    results = JaResource.Plug.call(conn, allowed: [:show])
    refute results.assigns[:handler]
  end

  test "it does not dispatch unknown actions to the behaviour" do
    conn = %Plug.Conn{
      private: %{
        phoenix_controller: JaResource.PlugTest.Example,
        phoenix_action:     :foo
      },
      params: %{}
    }
    results = JaResource.Plug.call(conn, allowed: [:index])
    refute results.assigns[:handler]
  end
end
