defmodule Docker.Names do
  @moduledoc """
  Docker name utility.
  """
  @default_registry "index.docker.io"

  @doc """
  Sanitizes a name for use with Docker.
  Docker doesn't support / in names, so convert them to underscores.

  ## Examples

      iex> Docker.Names.container_safe("foo")
      "foo"

      iex> Docker.Names.container_safe("foo/bar/bacon")
      "foo_bar_bacon"

      iex> Docker.Names.container_safe("foo_bar")
      "foo_bar"
  """
  def container_safe("/" <> name), do: "/" <> String.replace(name, "/", "_")
  def container_safe(name), do: String.replace(name, "/", "_")

  @doc """
  Ensures a name is prefixed with a "/" for matching against Docker's API.
  """
  def api(name = "/" <> _), do: name
  def api(name), do: "/" <> name

  @doc """
  Returns the tag of a Docker image given its name.

  ## Examples

      iex> Docker.Names.extract_tag("foo")
      "latest"

      iex > Docker.Names.extract_tag("foo:bar")
      "bar"

      iex > Docker.Names.extract_tag("foo/bar:bacon")
      "bacon"
  """
  def extract_tag([_image | []]), do: "latest"
  def extract_tag([_image | [tag]]), do: tag
  def extract_tag(image), do: image |> String.split(":") |> extract_tag

  @doc """
  Divides an image name into a tuple of {registry, repo, image}.

  ## Examples

      iex> Docker.Names.split_image("quay.io/wildcard/rabbitmq")
      {"quay.io", "wildcard", "rabbitmq"}

      iex> Docker.Names.split_image("dockerfile/rabbitmq")
      {"index.docker.io", "dockerfile", "rabbitmq"}

      iex> Docker.Names.split_image("ubuntu")
      {"index.docker.io", "_", "ubuntu"}
  """
  def split_image([name]), do: {@default_registry, "_", name}
  def split_image([repo, name]), do: {@default_registry, repo, name}
  def split_image([registry, repo, name]), do: {registry, repo, name}
  def split_image(image), do: image |> String.split("/") |> split_image
end
