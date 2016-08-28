ExUnit.start()

Application.put_env(:ja_resource, :repo, JaResourceTest.Repo)

defmodule JaResourceTest.Repo do
  @moduledoc """
  A fake repo implementation that just holds records in an agent.

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

  def all(query) do
    Agent.get __MODULE__, fn(state) ->
      Enum.filter state, fn(record) ->
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

  def insert(%Ecto.Changeset{valid?: true} = changeset) do
    insert(changeset.data)
  end

  def insert(%Ecto.Changeset{valid?: false} = changeset) do
    {:error, changeset}
  end

  def insert(record) do
    {Agent.update(__MODULE__, &MapSet.put(&1, record)), record}
  end

  def update(%Ecto.Changeset{valid?: true} = changeset) do
    insert(changeset.data)
  end

  def update(%Ecto.Changeset{valid?: false} = changeset) do
    {:error, changeset}
  end

  def update(new) do
    Agent.update __MODULE__, fn(state) ->
      old = Enum.find state, fn(record) ->
        record.__struct__ == new.__struct__ && record.id == new.id
      end
      state
      |> MapSet.delete(old)
      |> MapSet.put(Map.merge(old, new))
    end
  end

  def delete(to_delete) do
    Agent.update __MODULE__, fn(state) ->
      old = Enum.find state, fn(record) ->
        record.__struct__ == to_delete.__struct__ && record.id == to_delete.id
      end
      MapSet.delete(state, old)
    end
  end
end

# We don't actually need to use Ecto.Schema, just implement it's api.
defmodule JaResourceTest.Post do
  defstruct [id: 0, title: "title", body: "body", slug: "slug"]

  def changeset(_model, params) do
    model = %__MODULE__{
      title: params["title"],
      body:  params["body"],
      slug:  params["slug"]
    }
    case model.title do
      "invalid" -> %Ecto.Changeset{data: model, valid?: false, errors: [title: "is invalid"]}
      _         -> %Ecto.Changeset{data: model, valid?: true}
    end
  end
end

defmodule JaResourceTest.PostView do
  def render("errors.json", %{data: errors}),
    do: %{action: "errors.json", errors: render_errors(errors)}
  def render(action, opts),
    do: %{action: action, data: opts[:data]}

  defp render_errors(%Ecto.Changeset{errors: errors}),
    do: render_errors(errors)

  defp render_errors(errors),
    do: Enum.into(errors, %{})
end

JaResourceTest.Repo.start
