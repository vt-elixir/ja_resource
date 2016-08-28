defmodule JaResource.Mixfile do
  use Mix.Project

  def project do
    [app: :ja_resource,
     version: "0.1.0",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     package: package,
     description: description,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :phoenix]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:ecto, "~> 2.0"},
      {:plug, "~> 1.2"},
      {:phoenix, "~> 1.1"},
      {:ja_serializer, "~> 0.9"},
    ]
  end

  defp package do
    [
      licenses: ["Apache 2.0"],
      maintainers: ["Alan Peabody"],
      links: %{
        "GitHub" => "https://github.com/AgilionApps/ja_resource"
      },
    ]
  end

  defp description do
    """
    A behaviour for defining JSON-API spec controllers in Phoenix.

    Lets you focus on your data, not on boilerplate controller code.
    """
  end
end
