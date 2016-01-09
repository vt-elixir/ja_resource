defmodule JaResource.ModelTest do
  use ExUnit.Case

  import JaResource.Model

  test "model can be determined by the controller name" do
    assert model_from_controller(MyApp.SandwichController) == MyApp.Sandwich
    assert model_from_controller(MyApp.V1.SaladController) == MyApp.Salad
    assert model_from_controller(MyApp.API.V1.CookieController) == MyApp.Cookie
  end
end
