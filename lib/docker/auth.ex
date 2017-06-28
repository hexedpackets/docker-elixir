defmodule Docker.Auth do
  @doc """
  Authenticate to a docker registry.
  """
  def login(credentials) do
    Docker.Client.post("/auth", credentials)
  end
end
