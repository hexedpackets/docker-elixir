defmodule Docker.Images do
  @base_uri "/images"

  @doc """
  List all Docker images.
  """
  def list do
    "#{@base_uri}/json?all=true" |> Docker.Client.get
  end

  @doc """
  Return a filtered list of Docker images.
  """
  def list(filter) do
    "#{@base_uri}/json?filter=#{filter}" |> Docker.Client.get
  end

  @doc """
  Inspect a Docker image by name or id.
  """
  def inspect(name) do
    "#{@base_uri}/#{name}/json?all=true" |> Docker.Client.get
  end

  @doc """
  Pull a Docker image from the repo.
  """
  def pull(image), do: pull(image, "latest")
  def pull(image, tag) do
    "#{@base_uri}/create?fromImage=#{image}&tag=#{tag}"
    |> Docker.Client.post
  end

  @doc """
  Pull a Docker image as stream.
  """
  def pull_stream(image), do: pull_stream(image, "latest")
  def pull_stream(image, tag) do
    url = "#{@base_uri}/create?fromImage=#{image}&tag=#{tag}"
    Docker.Client.stream(:post, url)
  end


  @doc """
  Pull a Docker image from the repo after authenticating.
  """
  def pull(image, tag, auth) do
    auth_header = auth |> Poison.encode! |> Base.encode64
    headers = %{
      "X-Registry-Auth" => auth_header,
      "Content-Type" => "application/json"
    }

    "#{@base_uri}/create?fromImage=#{image}&tag=#{tag}"
    |> Docker.Client.post("", headers)
  end

  @doc """
  Deletes a local image.
  """
  def delete(image) do
    @base_uri <> "/" <> image |> Docker.Client.delete
  end
end
