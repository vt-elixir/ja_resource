defmodule JaResource.Model do
  @moduledoc """
  Provides the `model/0` callback used to customize the resource served.

  This behaviour is used by all JaResource actions.
  """

  @doc """
  Must return the module implementing `Ecto.Schema` to be represented.

  Example:

      def model, do: MyApp.Models.Post

  Defaults to the name of the controller, for example the controller
  `MyApp.V1.PostController` would serve the `MyApp.Post` model.

  Used by the default implementations for `handle_create/2`, `handle_update/3`,
  and `records/1`.
  """
  @callback model() :: module

  defmacro __using__(_) do
    quote do
      @behaviour JaResource.Model

      @inferred_model JaResource.Model.model_from_controller(__MODULE__)
      def model(), do: @inferred_model

      defoverridable [model: 0]
    end
  end

  def model_from_controller(module) do
    [_elixir, app | rest] = module
                            |> Atom.to_string
                            |> String.split(".")

    [controller | _ ] = Enum.reverse(rest)
    inferred = String.replace(controller, "Controller", "")

    String.to_atom("Elixir.#{app}.#{inferred}")
  end
end
