ExUnit.start()

Application.put_env(:ja_resource, :repo, JaResourceTest.Repo)


defmodule JaResourceTest.Repo do
  @moduledoc """
  A fake repo implimentation that just holds records in an agent.

  Usefull for testing w/o requiring a real repo.
  """

  def start do
    Agent.start_link(fn -> MapSet.new end, name: __MODULE__)
  end

  def reset do
    Agent.update(__MODULE__, fn(_old) -> MapSet.new end)
  end

  def one(query) do
    Agent.get __MODULE__, fn(state) -> 
      Enum.find state, fn(record) ->
        record.__struct__ == query
      end
    end
  end

  def get_by(query, [{field, val}]) do
    Agent.get __MODULE__, fn(state) -> 
      Enum.find state, fn(record) ->
        record.__struct__ == query && Map.get(record, field) == val
      end
    end
  end

  def get(query, id) do
    Agent.get __MODULE__, fn(state) -> 
      Enum.find state, fn(record) ->
        record.__struct__ == query && record.id == id
      end
    end
  end

  def insert(record) do
    Agent.update(__MODULE__, &MapSet.put(&1, record))
  end
end

defmodule JaResourceTest.Post do
  defstruct [id: 0, title: "title", body: "body", slug: "slug"]
end

JaResourceTest.Repo.start
