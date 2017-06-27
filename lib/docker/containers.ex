defmodule Docker.Containers do
  @base_uri "/containers"

  @doc """
  List all existing containers.
  """
  def list do
    "#{@base_uri}/json?all=true" |> Docker.Client.get
  end

  @doc """
  Inspect a container by ID.
  """
  def inspect(id) do
    "#{@base_uri}/#{id}/json" |> Docker.Client.get
  end

  @doc """
  Stop a running container.
  """
  def stop(id) do
    "#{@base_uri}/#{id}/stop" |> Docker.Client.post
  end

  @doc """
  Restart a container.
  """
  def restart(id) do
    "#{@base_uri}/#{id}/restart" |> Docker.Client.post
  end

  @doc """
  Remove a container. Assumes the container is already stopped.
  """
  def remove(id) do
    "#{@base_uri}/#{id}" |> Docker.Client.delete
  end

  @doc """
  Create a container from an existing image.
  """
  def create(conf) do
    Docker.Client.post("#{@base_uri}/create", conf)
  end
  def create(conf, name) do
    Docker.Client.post("#{@base_uri}/create?name=#{name}", conf)
  end

  @doc """
  Starts a newly created container.
  """
  def start(id) do
    Docker.Client.post("#{@base_uri}/#{id}/start", %{})
  end

  @doc """
  Starts a newly created container with a specified start config.
  The start config was deprecated as of v1.15 of the API, and all
  host parameters should be in the create configuration.
  """
  def start(id, conf) do
    Docker.Client.post("#{@base_uri}/#{id}/start", conf)
  end
end
