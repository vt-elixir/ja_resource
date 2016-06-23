defmodule JaResource.RepoTest do
  use ExUnit.Case

  Application.put_env(:ja_resource, :repo, MyApp.Repo)

  defmodule ExampleDefaultController do
    use JaResource
  end

  defmodule ExampleCustomController do
    use JaResource

    def repo, do: MyApp.SecondaryRepo
  end

  test "Repo should be poplulated from settings by default" do
    assert ExampleDefaultController.repo == MyApp.Repo
  end

  test "Repo can be overriden" do
    assert ExampleCustomController.repo == MyApp.SecondaryRepo
  end
end
