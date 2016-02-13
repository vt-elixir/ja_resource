defmodule JaResource.RecordsTest do
  use ExUnit.Case

  defmodule Default do
    use JaResource.Records
    def model, do: Model
  end

  defmodule Custom do
    use JaResource.Records
    def records(_), do: CustomModel
  end

  test "it should return the model by default" do
    assert Default.records(%{}) == Model
  end

  test "it should be allowed to be overriden" do
    assert Custom.records(%{}) == CustomModel
  end
end
