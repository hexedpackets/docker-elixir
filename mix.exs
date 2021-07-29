defmodule Docker.Mixfile do
  use Mix.Project

  @version File.read!("VERSION") |> String.trim()

  def project do
    [app: :docker,
     version: @version,
     elixir: "~> 1.3",
     deps: deps(),

     # Hex
     description: description(),
     package: package()]
  end

  def application do
    [applications: [:logger, :httpoison, :jason]]
  end

  defp deps do
    [
      {:jason, "~> 1.2"},
      {:httpoison, ">= 1.0.0"},
      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc, "~> 0.7", only: :dev},
    ]
  end

  defp description do
    """
    Elixir client for the Docker Remote API.
    """
  end

  defp package do
    [contributors: ["William Huba"],
     licenses: ["Apache 2.0"],
     links: %{"GitHub" => "https://github.com/hexedpackets/docker-elixir"},
     files: ~w(mix.exs README.md LICENSE VERSION config lib)]
  end
end
