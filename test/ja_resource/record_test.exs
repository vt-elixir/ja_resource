defmodule JaResource.RecordTest do
  use ExUnit.Case, async: false

  defmodule Default do
    use JaResource.Record
    def repo, do: JaResourceTest.Repo
    def records(_), do: JaResourceTest.Post
  end

  defmodule Custom do
    use JaResource.Record
    def records(_), do: JaResourceTest.Post
    def record(query, id) do
      JaResourceTest.Repo.get_by(query, slug: id)
    end
  end

  test "it should return the model by default" do
    JaResourceTest.Repo.insert(%JaResourceTest.Post{id: 1})
    assert Default.record(JaResourceTest.Post, 1) == %JaResourceTest.Post{id: 1}
    JaResourceTest.Repo.reset
  end

  test "it should be allowed to be overriden" do
    record = %JaResourceTest.Post{id: 2, slug: "foo"}
    JaResourceTest.Repo.insert(record)
    assert Custom.record(JaResourceTest.Post, "foo") == record
    JaResourceTest.Repo.reset
  end
end
