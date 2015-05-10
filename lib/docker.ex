defmodule Docker do
  @doc """
  Display system-wide information.
  """
  def info, do: Docker.Client.get("/info")

  @doc """
  Show the docker version information.
  """
  def version, do: Docker.Client.get("/version")

  @doc """
  Ping the docker server.
  """
  def ping, do: Docker.Client.get("/_ping")

  @doc """
  Monitor Docker's events.
  """
  def events(since), do: Docker.Client.get("/events?since=#{since}")
end
