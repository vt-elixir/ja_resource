defmodule JaResource.ModelTest do
  use ExUnit.Case

  import JaResource.Model

  defmodule DefaultController do
    use JaResource.Model
  end

  defmodule CustomController do
    use JaResource.Model
    def model, do: Customized
  end

  test "model can be determined by the controller name" do
    assert model_from_controller(MyApp.SandwichController) == MyApp.Sandwich
    assert model_from_controller(MyApp.V1.SaladController) == MyApp.Salad
    assert model_from_controller(MyApp.API.V1.CookieController) == MyApp.Cookie
  end

  test "model is inferred by default" do
    assert DefaultController.model == JaResource.Default
  end

  test "model can be overridded" do
    assert CustomController.model == Customized
  end
end
