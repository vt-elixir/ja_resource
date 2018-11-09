defmodule JaResource.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ja_resource,
      version: "0.3.1",
      elixir: "~> 1.2",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      source_url: "https://github.com/vt-elixir/ja_resource",
      package: package(),
      description: description(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application
  def application do
    [applications: [:logger, :phoenix]]
  end

  defp deps do
    [
      {:ecto, "~> 3.0"},
      {:plug, "~> 1.2"},
      {:phoenix, "~> 1.4"},
      {:ja_serializer, "~> 0.9"},
      {:earmark, "~> 1.0.1", only: :dev},
      {:ex_doc, "~> 0.13", only: :dev}
    ]
  end

  defp package do
    [
      licenses: ["Apache 2.0"],
      maintainers: ["Alan Peabody", "Pete Brown"],
      links: %{
        "GitHub" => "https://github.com/vt-elixir/ja_resource"
      }
    ]
  end

  defp description do
    """
    A behaviour for defining JSON-API spec controllers in Phoenix.

    Lets you focus on your data, not on boilerplate controller code. Like Webmachine for Phoenix.
    """
  end
end
