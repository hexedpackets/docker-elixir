defmodule Docker.Misc do
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
  @doc """
  Monitor Docker's events as stream.
  """
  def events_stream, do: Docker.Client.stream(:get, "/events")
  def events_stream(filter) do
    json = filter |> Poison.encode!
    Docker.Client.stream(:get, "/events?filters=#{json}")
  end
end
