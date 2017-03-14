defmodule JaResource.Mixfile do
  use Mix.Project

  def project do
    [app: :ja_resource,
     version: "0.4.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     source_url: "https://github.com/AgilionApps/ja_resource",
     package: package(),
     description: description(),
     deps: deps()]
  end

  # Configuration for the OTP application
  def application do
    [extra_applications: []]
  end

  defp deps do
    [
      {:ecto, "~> 2.1.4"},
      {:plug, "~> 1.3.2"},
      {:phoenix, "1.3.0-rc.0"},
      {:ja_serializer, "~> 0.12.0"},

      {:earmark, "~> 1.1", only: :dev},
      {:ex_doc,  "~> 0.14.5", only: :dev},
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

    Lets you focus on your data, not on boilerplate controller code. Like Webmachine for Phoenix.
    """
  end
end
